package uk.gov.legislation.db2.rds;

import java.sql.*;
import java.util.Date;
import java.util.*;

public class Document {

	private final String id;
	private final int year;
	private String title;
	private Date updated;
	private Date checked;

	public Document(String id, int year) {
		if (id.startsWith("http://www.legislation.gov.uk/id/"))
			id = id.substring(33);
		this.id = id;
		this.year = year;
		this.checked = new Date();
	}

	private Document(ResultSet result) throws SQLException {
		id = result.getString("id");
		year = result.getInt("year");
		title = result.getString("title");
		updated = result.getTimestamp("updated");
		checked = result.getTimestamp("checked");
	}

	public String id() {
		return id;
	}

	public int year() {
		return year;
	}

	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}

	public Date getLastUpdated() {
		return updated;
	}
	public void setLastUpdated(Date updated) {
		this.updated = updated;
	}

	public Date getLastChecked() {
		return checked;
	}
	public void setLastChecked(Date checked) {
		this.checked = checked;
	}

	public static List<Document> fetch(String type) throws SQLException {
		List<Document> docs = new LinkedList<>();
		String sql = "SELECT * FROM documents WHERE type = ? ORDER BY year DESC, number";
		Connection connection = MySQL.getConnection();
		try {
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setString(1, type);
			ResultSet result = statement.executeQuery();
			while (result.next()) {
				Document doc = new Document(result);
				docs.add(doc);
			}
			result.close();
			statement.close();
		} finally {
			connection.close();
		}
		return docs;
	}

	public static NavigableSet<Integer> getYears(Connection connection, String type) throws SQLException {
		TreeSet<Integer> years = new TreeSet<>();
		String sql = "SELECT DISTINCT year FROM documents WHERE type = ?";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setString(1, type);
		ResultSet result = statement.executeQuery();
		while (result.next()) {
			int year = result.getInt(1);
			years.add(year);
		}
		result.close();
		statement.close();
		return years;
	}
	public static NavigableSet<Integer> getYears(String type) throws SQLException {
		Connection connection = MySQL.getConnection();
		try {
			return getYears(connection, type);
		} finally {
			connection.close();
		}
	}

	public static List<Document> fetch(Connection connection, String type, int year) throws SQLException {
		List<Document> docs = new LinkedList<>();
		String sql = "SELECT * FROM documents WHERE type = ? AND year = ? ORDER BY number";
		PreparedStatement statement = connection.prepareStatement(sql);
		statement.setString(1, type);
		statement.setInt(2, year);
		ResultSet result = statement.executeQuery();
		while (result.next()) {
			Document doc = new Document(result);
			docs.add(doc);
		}
		result.close();
		statement.close();
		return docs;
	}

	public static List<Document> fetch(String type, int year) throws SQLException {
		List<Document> docs = new LinkedList<>();
		String sql = "SELECT * FROM documents WHERE type = ? AND year = ? ORDER BY number";
		Connection connection = MySQL.getConnection();
		try {
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setString(1, type);
			statement.setInt(2, year);
			ResultSet result = statement.executeQuery();
			while (result.next()) {
				Document doc = new Document(result);
				docs.add(doc);
			}
			result.close();
			statement.close();
		} finally {
			connection.close();
		}
		return docs;
	}

	public static Document get(String id) throws SQLException {
		Document doc;
		String sql = "SELECT * FROM documents WHERE id = ?";
		Connection connection = MySQL.getConnection();
		try {
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setString(1, id);
			ResultSet result = statement.executeQuery();
			if (result.next())
				doc = new Document(result);
			else
				doc = null;
			result.close();
			statement.close();
		} finally {
			connection.close();
		}
		return doc;
	}

	public void put() throws SQLException {
		String sql = "INSERT INTO documents (id, type, year, number, title, updated, checked) VALUES (?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE year = ?, title = ?, updated = ?, checked = ?";
		Connection connection = MySQL.getConnection();
		try {
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setString(1, id);
			String type = id.substring(0, id.indexOf('/'));
			statement.setString(2, type);
			statement.setInt(3, year);
			long number = Long.parseLong(id.substring(id.lastIndexOf('/') + 1));
			statement.setLong(4, number);
			statement.setString(5, title);
			if (updated == null)
				statement.setNull(6, Types.TIMESTAMP);
			else
				statement.setTimestamp(6, new Timestamp(updated.getTime()));
			if (checked == null)
				statement.setNull(7, Types.TIMESTAMP);
			else
				statement.setTimestamp(7, new Timestamp(checked.getTime()));
			statement.setInt(8, year);
			statement.setString(9, title);
			if (updated == null)
				statement.setNull(10, Types.TIMESTAMP);
			else
				statement.setTimestamp(10, new Timestamp(updated.getTime()));
			if (checked == null)
				statement.setNull(11, Types.TIMESTAMP);
			else
				statement.setTimestamp(11, new Timestamp(checked.getTime()));
			statement.executeUpdate();
			statement.close();
		} finally {
			connection.close();
		}
	}

	public static Date getLastUpdated(String type) throws SQLException {
		Date date;
		String sql = "SELECT MAX(updated) FROM documents WHERE type = ?";
		Connection connection = MySQL.getConnection();
		try {
			PreparedStatement statement = connection.prepareStatement(sql);
			statement.setString(1, type);
			ResultSet result = statement.executeQuery();
			if (result.next())
				date = result.getTimestamp(1);
			else
				date = null;
			result.close();
			statement.close();
		} finally {
			connection.close();
		}
		return date;
	}

}
