package uk.gov.legislation.db2.rds;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mysql.cj.jdbc.MysqlDataSource;
import software.amazon.awssdk.regions.Region;
import uk.gov.legislation.aws.Secrets;

import java.sql.Connection;
import java.sql.SQLException;

public class MySQL {

	private static final Region region = Region.EU_WEST_2;
	private static final String CredentialsSecretName = "mysql1-credentials-java";
	private static final String Database = "legislation";

	private static final String Host;
	private static final int Port;
	private static final String Username;
	private static final String Password;
	static {
		String json;
		try {
			json = Secrets.getSecret(region, CredentialsSecretName);
		} catch (Exception e) {
			e.printStackTrace();
			json = null;
		}
		if (json == null) {
			Host = null;
			Port = 0;
			Username = null;
			Password = null;
		} else {
			JsonNode credentials;
			try {
				credentials = new ObjectMapper().readTree(json);
			} catch (JsonProcessingException e) {
				credentials = null;
			}
			if (credentials == null) {
				Host = null;
				Port = 0;
				Username = null;
				Password = null;
			} else {
				Host = credentials.get("host").textValue();
				Port = credentials.get("port").intValue();
				Username = credentials.get("username").textValue();
				Password = credentials.get("password").textValue();
			}
		}
	}

	private static final MysqlDataSource db = new MysqlDataSource();
	static {
		db.setServerName(Host);
		db.setPortNumber(Port);
//		db.setSsl(useSsl);
		db.setUser(Username);
		db.setPassword(Password);
		db.setDatabaseName(Database);
		try {
			db.setServerTimezone("UTC");
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
	}

	public static Connection getConnection() throws SQLException {
		return db.getConnection();
	}

}
