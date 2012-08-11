/* 
 * NativeBOINC - Native BOINC Client with Manager
 * Copyright (C) 2011, Mateusz Szpakowski
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 */
package sk.boinc.nativeboinc.news;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * @author mat
 *
 */
public class NewsMessage implements Parcelable {
	private long timestamp = 0;
	private String title = null;
	private String content = null;

	public static final Parcelable.Creator<NewsMessage> CREATOR
		= new Parcelable.Creator<NewsMessage>() {
			@Override
			public NewsMessage createFromParcel(Parcel in) {
				return new NewsMessage(in);
			}
	
			@Override
			public NewsMessage[] newArray(int size) {
				return new NewsMessage[size];
			}
	};
	
	public NewsMessage() {
	}
	
	private NewsMessage(Parcel in) {
		timestamp = in.readLong();
		title = in.readString();
		content = in.readString();
	}
	
	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeLong(timestamp);
		dest.writeString(title);
		dest.writeString(content);
	}
	
	public long getTimestamp() {
		return timestamp;
	}
	
	public void setTimestamp(long timestamp) {
		this.timestamp = timestamp;
	}
	
	public String getTitle() {
		return title;
	}
	
	public void setTitle(String title) {
		this.title = title;
	}
	
	public String getContent() {
		return content;
	}
	
	public void setContent(String content) {
		this.content = content;
	}
}
