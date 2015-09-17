/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.apache.flume.source.taildir;

import static org.apache.flume.source.taildir.TaildirSourceConfigurationConstants.*;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.apache.flume.Event;
import org.apache.flume.event.EventBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Charsets;
import com.google.common.collect.Lists;
import com.google.common.io.ByteArrayDataOutput;
import com.google.common.io.ByteStreams;

public class TailFile {
  private static final Logger logger = LoggerFactory.getLogger(TailFile.class);

  private static final String LINE_SEP = "\n";
  private static final String LINE_SEP_WIN = "\r\n";

  private RandomAccessFile raf;
  private final String path;
  private final long inode;
  private long pos;
  private long lastUpdated; //明确定义： 上次本应用处理的时间，包括clone操作
  private boolean needTail;
  private final Map<String, String> headers;

  public TailFile(File file, Map<String, String> headers, long inode, long pos)
      throws IOException {
    this.raf = new RandomAccessFile(file, "r");
    if (pos > 0) raf.seek(pos);
    this.path = file.getAbsolutePath();
    this.inode = inode;
    this.pos = pos;
    this.lastUpdated = 0L;
    this.needTail = true;
    this.headers = headers;
  }

  public RandomAccessFile getRaf() {
    return raf;
  }

  public String getPath() {
    return path;
  }

  public long getInode() {
    return inode;
  }

  public long getPos() {
    return pos;
  }

  public long getLastUpdated() {
    return lastUpdated;
  }

  public boolean needTail() {
    return needTail;
  }

  public Map<String, String> getHeaders() {
    return headers;
  }

  public void setPos(long pos) {
    this.pos = pos;
  }

  public void setLastUpdated(long lastUpdated) {
    this.lastUpdated = lastUpdated;
  }

  public void setNeedTail(boolean needTail) {
    this.needTail = needTail;
  }

  public boolean updatePos(String path, long inode, long pos) throws IOException {
    long newPos = pos;
    if (raf.length() < pos) {
      logger.info("Pos " + pos + " is larger than file size! "
          + "Restarting from pos 0, file: " + path + ", inode: " + inode);
      newPos = 0;
    }

    if (this.inode == inode && this.path.equals(path)) {
      raf.seek(newPos);
      setPos(newPos);
      logger.info("Updated position, file: " + path + ", inode: " + inode + ", pos: " + newPos);
      return true;
    }
    return false;
  }

  public List<Event> readEvents(int numEvents, boolean backoffWithoutNL,
                                boolean addByteOffset) throws IOException {
    List<Event> events = Lists.newLinkedList();
    if (needTail) {
      for (int i = 0; i < numEvents; i++) {
        Event event = readEvent(backoffWithoutNL, addByteOffset);
        if (event == null) {
          break;
        }
        events.add(event);
      }
    }
    return events;
  }

  private Event readEvent(boolean backoffWithoutNL, boolean addByteOffset) throws IOException {
    Long posTmp = raf.getFilePointer();
    String line = readLine();
    if (line == null) {
      return null;
    }
//    while (emptyLinePattern.matcher(line).matches()) {
//      logger.info("occur one empty line, so slip it and go on readLine.");
//      line = readLine();
//    }
    if (backoffWithoutNL && !line.endsWith(LINE_SEP)) {
      logger.info("Backing off in file without newline: "
          + path + ", inode: " + inode + ", pos: " + raf.getFilePointer());
      raf.seek(posTmp);
      return null;
    }

    String lineSep = LINE_SEP;
    if (line.endsWith(LINE_SEP_WIN)) {
      lineSep = LINE_SEP_WIN;
    }
    Event event = EventBuilder.withBody(StringUtils.removeEnd(line, lineSep), Charsets.UTF_8);
    if (addByteOffset == true) {
      event.getHeaders().put(BYTE_OFFSET_HEADER_KEY, posTmp.toString());
    }
    return event;
  }

  private String readLine() throws IOException {
    ByteArrayDataOutput out = ByteStreams.newDataOutput(300);
    int i = 0;
    int c;
    while ((c = raf.read()) != -1) {
      i++;
      out.write((byte) c);
      if (c == LINE_SEP.charAt(0)) {
        break;
      }
    }
    if (i == 0) {
      return null;
    }
    return new String(out.toByteArray(), Charsets.UTF_8);
  }

  public void close() {
    try {
      raf.close();
      raf = null;
      long now = System.currentTimeMillis();
      setLastUpdated(now); //重新创建tf对象时，会init lastUpdated=0
    } catch (IOException e) {
      logger.error("Failed closing file: " + path + ", inode: " + inode, e);
    }
  }

  public static class CompareByLastModifiedTime implements Comparator<File> {
    @Override
    public int compare(File f1, File f2) {
      return Long.valueOf(f1.lastModified()).compareTo(f2.lastModified());
    }
  }


}
