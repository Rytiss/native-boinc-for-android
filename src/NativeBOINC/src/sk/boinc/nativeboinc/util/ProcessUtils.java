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
package sk.boinc.nativeboinc.util;

import android.content.Context;

/**
 * @author mat
 *
 */
public class ProcessUtils {

	public native static int exec(String program, String dirPath, String[] args);
	public native static int execSD(String program, String dirPath, String[] args);
	public native static int waitForProcess(int pid) throws InterruptedException;
	
	public native static int bugCatchExec(String program, String dirPath, String[] args);
	public native static int bugCatchInit(int pid);
	public native static int bugCatchExecSD(String program, String dirPath, String[] args);
	public native static int bugCatchWaitForProcess(Context context, int pid) throws InterruptedException;
	
	static {
		System.loadLibrary("nativeboinc_utils");
	}
}
