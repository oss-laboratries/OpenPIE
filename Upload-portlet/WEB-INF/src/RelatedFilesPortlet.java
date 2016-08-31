import java.io.*;

import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;

import org.apache.commons.io.FileUtils;

import com.liferay.portal.kernel.upload.UploadPortletRequest;
import com.liferay.portal.util.PortalUtil;
import com.liferay.util.bridges.mvc.MVCPortlet;


public class RelatedFilesPortlet extends MVCPortlet {

	private final static int ONE_GB = 1073741824;
	private final static String baseDir = "/opt/liferay/file";	
	private final static String fileInputName = "fileupload";
	
	
	public void upload(ActionRequest request, ActionResponse response) throws Exception {


		UploadPortletRequest uploadRequest = PortalUtil.getUploadPortletRequest(request);


		//long sizeInBytes = uploadRequest.getSize(fileInputName);

		if (uploadRequest.getSize(fileInputName) ==  0){
			throw new Exception("Received file is bytes!");
		}

		// Get the uploaded file as a file.
		File uploadedFile = uploadRequest.getFile(fileInputName);
 
		String sourceFileName = uploadRequest.getFileName(fileInputName);
 
		
		// Where should we store this file?
		File folder = new File(baseDir);
 
		// Check minimum B storage space to save new files...
		
		if (folder.getUsableSpace() < ONE_GB) {
			throw new Exception("Out of disk space!");
		}
 
		// This is our final file path.
		File filePath = new File(folder.getAbsolutePath() + File.separator + sourceFileName);
 
		// Move the existing temporary file to new location.
		FileUtils.copyFile(uploadedFile, filePath);
		
		System.out.println("UPFL=" +sourceFileName);
		System.out.println("Stert");

		
		/*
		String shellPath = "/opt/liferay-portal-6.2-ce-ga6/tomcat-7.0.62/webapps/Upload-portlet/upload.sh";
		String localImgpath = "/opt/liferay/file/aaa";
		String ip = "192.168.100.242";
		String copyToImgPath = "/tmp/file";
		*/

		String dir = "/opt/liferay/config/";
		String git_cfg = "portlet_config";
		String lifepath = "";
		String flserver = "";
		String fluser = "";
		String flpass = "";
		String cpPath = "";
		// GitLab情報の取得
		BufferedReader in = new BufferedReader(new FileReader(dir + git_cfg));
		while (true) {
			String s = in.readLine();
			if (s == null) {
				break;
			}
			int index = s.indexOf("=");
			if (s.matches("^FLServer=.*")){
				flserver = s.substring(index+1);
			}
			else if (s.matches("^Liferay_Tomcat_Path=.*")){
				lifepath = s.substring(index+1);
			}
			else if (s.matches("^FLUser=.*")){
				fluser = s.substring(index+1);
			}
			else if (s.matches("^FLPassword=.*")){
				flpass = s.substring(index+1);
			}
			else if (s.matches("^FLUploadpath=.*")){
				cpPath = s.substring(index+1);
			}
		}
		in.close();

		flserver = flserver.replaceAll("http://","");
		
		lifepath = lifepath+"/webapps/Upload-portlet/upload.sh";
		System.out.println(flserver);
		System.out.println("FLUser="+fluser);
		System.out.println("FLPASS="+flpass);
		String path = "/opt/liferay/file/";
//		String fl = "ParamaterSeet.xlsx";
//		String fl = "aa.txt";
		String fl = sourceFileName;
		String flpath=path + fl;
		//String cpPath = "/var/sfj/upload/";
		
		String command = "/bin/sh " + lifepath + " " + flpath + " " + flserver + " " + cpPath + " " + fluser + " " + flpass;
//		String command = "/bin/sh "+ shellPath;
		System.out.println(command);
		Process ps = Runtime.getRuntime().exec(command);
		ps.waitFor();
		System.out.println("End");

		
		
	}
 
}