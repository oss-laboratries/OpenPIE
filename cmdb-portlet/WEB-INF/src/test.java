import java.util.*;
import java.util.Map;
import java.text.SimpleDateFormat;
import org.codehaus.jackson.*;
import java.io.*;
import org.json.JSONObject;

public class test {
	public static void main(String[] args) throws Exception {
		String description="";
		String comments="";
		String hostname = "";
		String mg="";

		String json = "[{\"expression\":\"{13200}<20\",\"flags\":\"4\",\"error\":\"\",\"status\":\"0\",\"state\":\"0\",\"templateid\":\"0\",\"type\":\"0\",\"lastchange\":\"1468499767\",\"url\":\"\",\"triggerid\":\"13597\",\"description\":\"Free disk space is less than 20% on volume /\",\"priority\":\"2\",\"hosts\":[{\"maintenance_type\":\"0\",\"ipmi_privilege\":\"2\",\"tls_subject\":\"\",\"maintenance_from\":\"0\",\"ipmi_username\":\"\",\"ipmi_disable_until\":\"0\",\"ipmi_errors_from\":\"0\",\"jmx_disable_until\":\"0\",\"tls_psk\":\"\",\"errors_from\":\"0\",\"jmx_available\":\"0\",\"ipmi_password\":\"\",\"ipmi_error\":\"\",\"description\":\"\",\"name\":\"192.168.100.242\",\"disable_until\":\"0\",\"tls_psk_identity\":\"\",\"jmx_errors_from\":\"0\",\"ipmi_authtype\":\"-1\",\"maintenanceid\":\"0\",\"tls_connect\":\"1\",\"flags\":\"0\",\"host\":\"192.168.100.242\",\"error\":\"\",\"snmp_available\":\"0\",\"status\":\"0\",\"templateid\":\"0\",\"tls_issuer\":\"\",\"tls_accept\":\"1\",\"available\":\"1\",\"lastaccess\":\"0\",\"ipmi_available\":\"0\",\"snmp_disable_until\":\"0\",\"maintenance_status\":\"0\",\"hostid\":\"10113\",\"proxy_hostid\":\"0\",\"jmx_error\":\"\",\"snmp_error\":\"\",\"snmp_errors_from\":\"0\"}],\"value\":\"1\",\"comments\":\"\"},{\"expression\":\"{13172}=1\",\"flags\":\"0\",\"error\":\"\",\"status\":\"0\",\"state\":\"0\",\"templateid\":\"10047\",\"type\":\"0\",\"lastchange\":\"1468499490\",\"url\":\"\",\"triggerid\":\"13569\",\"description\":\"Zabbix agent on {HOST.NAME} is unreachable for 5 minutes\",\"priority\":\"3\",\"hosts\":[{\"maintenance_type\":\"0\",\"ipmi_privilege\":\"2\",\"tls_subject\":\"\",\"maintenance_from\":\"0\",\"ipmi_username\":\"\",\"ipmi_disable_until\":\"0\",\"ipmi_errors_from\":\"0\",\"jmx_disable_until\":\"0\",\"tls_psk\":\"\",\"errors_from\":\"1468499204\",\"jmx_available\":\"0\",\"ipmi_password\":\"\",\"ipmi_error\":\"\",\"description\":\"\",\"name\":\"192.168.100.241\",\"disable_until\":\"1468575228\",\"tls_psk_identity\":\"\",\"jmx_errors_from\":\"0\",\"ipmi_authtype\":\"-1\",\"maintenanceid\":\"0\",\"tls_connect\":\"1\",\"flags\":\"0\",\"host\":\"192.168.100.241\",\"error\":\"Get value from agent failed: cannot connect to [[192.168.100.241]:10050]: [111] Connection refused\",\"snmp_available\":\"0\",\"status\":\"0\",\"templateid\":\"0\",\"tls_issuer\":\"\",\"tls_accept\":\"1\",\"available\":\"2\",\"lastaccess\":\"0\",\"ipmi_available\":\"0\",\"snmp_disable_until\":\"0\",\"maintenance_status\":\"0\",\"hostid\":\"10111\",\"proxy_hostid\":\"0\",\"jmx_error\":\"\",\"snmp_error\":\"\",\"snmp_errors_from\":\"0\"}],\"value\":\"1\",\"comments\":\"\"},{\"expression\":\"{13193}<50\",\"flags\":\"0\",\"error\":\"\",\"status\":\"0\",\"state\":\"0\",\"templateid\":\"10012\",\"type\":\"0\",\"lastchange\":\"1468496830\",\"url\":\"\",\"triggerid\":\"13590\",\"description\":\"Lack of free swap space on {HOST.NAME}\",\"priority\":\"2\",\"hosts\":[{\"maintenance_type\":\"0\",\"ipmi_privilege\":\"2\",\"tls_subject\":\"\",\"maintenance_from\":\"0\",\"ipmi_username\":\"\",\"ipmi_disable_until\":\"0\",\"ipmi_errors_from\":\"0\",\"jmx_disable_until\":\"0\",\"tls_psk\":\"\",\"errors_from\":\"0\",\"jmx_available\":\"0\",\"ipmi_password\":\"\",\"ipmi_error\":\"\",\"description\":\"\",\"name\":\"192.168.100.242\",\"disable_until\":\"0\",\"tls_psk_identity\":\"\",\"jmx_errors_from\":\"0\",\"ipmi_authtype\":\"-1\",\"maintenanceid\":\"0\",\"tls_connect\":\"1\",\"flags\":\"0\",\"host\":\"192.168.100.242\",\"error\":\"\",\"snmp_available\":\"0\",\"status\":\"0\",\"templateid\":\"0\",\"tls_issuer\":\"\",\"tls_accept\":\"1\",\"available\":\"1\",\"lastaccess\":\"0\",\"ipmi_available\":\"0\",\"snmp_disable_until\":\"0\",\"maintenance_status\":\"0\",\"hostid\":\"10113\",\"proxy_hostid\":\"0\",\"jmx_error\":\"\",\"snmp_error\":\"\",\"snmp_errors_from\":\"0\"}],\"value\":\"1\",\"comments\":\"It probably means that the systems requires more physical memory.\"},{\"expression\":\"{12909}<50\",\"flags\":\"0\",\"error\":\"\",\"status\":\"0\",\"state\":\"0\",\"templateid\":\"10012\",\"type\":\"0\",\"lastchange\":\"1468470030\",\"url\":\"\",\"triggerid\":\"13500\",\"description\":\"Lack of free swap space on {HOST.NAME}\",\"priority\":\"2\",\"hosts\":[{\"maintenance_type\":\"0\",\"ipmi_privilege\":\"2\",\"tls_subject\":\"\",\"maintenance_from\":\"0\",\"ipmi_username\":\"\",\"ipmi_disable_until\":\"0\",\"ipmi_errors_from\":\"0\",\"jmx_disable_until\":\"0\",\"tls_psk\":\"\",\"errors_from\":\"0\",\"jmx_available\":\"0\",\"ipmi_password\":\"\",\"ipmi_error\":\"\",\"description\":\"\",\"name\":\"localhost\",\"disable_until\":\"0\",\"tls_psk_identity\":\"\",\"jmx_errors_from\":\"0\",\"ipmi_authtype\":\"-1\",\"maintenanceid\":\"0\",\"tls_connect\":\"1\",\"flags\":\"0\",\"host\":\"localhost\",\"error\":\"\",\"snmp_available\":\"0\",\"status\":\"1\",\"templateid\":\"0\",\"tls_issuer\":\"\",\"tls_accept\":\"1\",\"available\":\"0\",\"lastaccess\":\"0\",\"ipmi_available\":\"0\",\"snmp_disable_until\":\"0\",\"maintenance_status\":\"0\",\"hostid\":\"10084\",\"proxy_hostid\":\"0\",\"jmx_error\":\"\",\"snmp_error\":\"\",\"snmp_errors_from\":\"0\"}],\"value\":\"1\",\"comments\":\"It probably means that the systems requires more physical memory.\"},{\"expression\":\"{13164}<20\",\"flags\":\"4\",\"error\":\"\",\"status\":\"0\",\"state\":\"0\",\"templateid\":\"0\",\"type\":\"0\",\"lastchange\":\"1468408469\",\"url\":\"\",\"triggerid\":\"13561\",\"description\":\"Free disk space is less than 20% on volume /\",\"priority\":\"2\",\"hosts\":[{\"maintenance_type\":\"0\",\"ipmi_privilege\":\"2\",\"tls_subject\":\"\",\"maintenance_from\":\"0\",\"ipmi_username\":\"\",\"ipmi_disable_until\":\"0\",\"ipmi_errors_from\":\"0\",\"jmx_disable_until\":\"0\",\"tls_psk\":\"\",\"errors_from\":\"0\",\"jmx_available\":\"0\",\"ipmi_password\":\"\",\"ipmi_error\":\"\",\"description\":\"\",\"name\":\"localhost\",\"disable_until\":\"0\",\"tls_psk_identity\":\"\",\"jmx_errors_from\":\"0\",\"ipmi_authtype\":\"-1\",\"maintenanceid\":\"0\",\"tls_connect\":\"1\",\"flags\":\"0\",\"host\":\"localhost\",\"error\":\"\",\"snmp_available\":\"0\",\"status\":\"1\",\"templateid\":\"0\",\"tls_issuer\":\"\",\"tls_accept\":\"1\",\"available\":\"0\",\"lastaccess\":\"0\",\"ipmi_available\":\"0\",\"snmp_disable_until\":\"0\",\"maintenance_status\":\"0\",\"hostid\":\"10084\",\"proxy_hostid\":\"0\",\"jmx_error\":\"\",\"snmp_error\":\"\",\"snmp_errors_from\":\"0\"}],\"value\":\"1\",\"comments\":\"\"}]";
		//System.out.println(json);


		String strBefore1="},";
		String strAfter1="}]\n[";
		json=json.replaceAll(strBefore1, strAfter1);
		String[] array = json.split("\n");
		System.out.println(json);

		for(int i=0; i< array.length; i++){
			System.out.println(i +array[i]);

			JsonFactory factory = new JsonFactory();
			JsonParser parser = factory.createJsonParser(array[i]);
			if (parser.nextToken() == JsonToken.START_ARRAY) {
				while (parser.nextToken() != JsonToken.END_ARRAY) {
					if (parser.getCurrentToken() == JsonToken.START_OBJECT) {
						while (parser.nextToken() != JsonToken.END_OBJECT) {

							String name = parser.getCurrentName();

							if(name != null) {
								parser.nextToken();
								if (name.equals("hosts")) {
									hostname = sub(parser.getCurrentName(),array[i]);
								}
								if (name.equals("description")) {
									description = parser.getText();
									System.out.println("description="+parser.getText());
								}	
								if (name.equals("comments")) {
									comments = parser.getText();
									System.out.println("comments="+parser.getText());
								}

								else{
									parser.skipChildren();
								}
							}
						}
						mg = hostname + comments + "		"+description;
						System.out.println("MG="+mg);
					}
				}
			}
		}
	}
	static String sub(String api,String json) throws IOException {
		String hname = "";
		JsonFactory factory = new JsonFactory();
		JsonParser parser = factory.createJsonParser(json);
		while (parser.nextToken() != JsonToken.END_OBJECT) {
			String name1 = parser.getCurrentName();

			if(name1 != null) {
				parser.nextToken();
				if (name1.equals("host")) {
					hname = parser.getText();
					System.out.println("host=="+parser.getText());
				}
			}
		}
		System.out.println("NAME="+hname);
		return hname;
	}
}


