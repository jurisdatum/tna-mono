package uk.gov.legislation.db2.rds;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Collection;
import java.util.Iterator;

public class Version {

    public static void save(String id, Collection<String> versions) throws SQLException {
        if (versions.isEmpty())
            return;
        String delete = "DELETE FROM versions WHERE doc_id = ?";
        Connection connection = MySQL.getConnection();
        connection.setAutoCommit(false);
        try {
            PreparedStatement statement1 = connection.prepareStatement(delete);
            statement1.setString(1, id);
            statement1.executeUpdate();
            statement1.close();
            String add = "INSERT INTO versions (doc_id, name) VALUES";
            Iterator<String> it = versions.iterator();
            if (it.hasNext()) {
                it.next();
                add += " (?, ?)";
            }
            while (it.hasNext()) {
                it.next();
                add += ", (?, ?)";
            }
            PreparedStatement statement2 = connection.prepareStatement(add);
            it = versions.iterator();
            int i = 0;
            while (it.hasNext()) {
                String version = it.next();
                int offset = i * 2;
                statement2.setString( offset + 1, id);
                statement2.setString(offset + 2, version);
                i += 1;
            }
            statement2.executeUpdate();
            statement2.close();
            connection.commit();
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.close();
        }
    }
}
