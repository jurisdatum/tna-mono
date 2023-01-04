package uk.gov.legislation.db2.rds;

import uk.gov.legislation.cites.Cite;
import uk.gov.legislation.cites.EmbeddedCite;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;
import java.util.ListIterator;

public class Citations {

    public static void save(String id, List<EmbeddedCite> cites) throws SQLException {
        if (cites.isEmpty())
            return;
        String delete = "DELETE FROM citations WHERE id = ? ORDER BY number";
        Connection connection = MySQL.getConnection();
        connection.setAutoCommit(false);
        try {
            PreparedStatement statement1 = connection.prepareStatement(delete);
            statement1.setString(1, id);
            statement1.executeUpdate();
            statement1.close();
            String add = "INSERT INTO citations (id, section, type, year, number, text) VALUES";
            ListIterator<EmbeddedCite> it = cites.listIterator();
            if (it.hasNext()) {
                it.next();
                add += " (?, ?, ?, ?, ?, ?)";
            }
            while (it.hasNext()) {
                it.next();
                add += ", (?, ?, ?, ?, ?, ?)";
            }
            PreparedStatement statement2 = connection.prepareStatement(add);
            it = cites.listIterator();
            while (it.hasNext()) {
                int i = it.nextIndex();
                EmbeddedCite embedded = it.next();
                String section = embedded.section();
                Cite cite = embedded.cite();
                final int offset = i * 6;
                statement2.setString( offset + 1, id);
                if (section == null)
                    statement2.setNull(offset + 2, Types.VARCHAR);
                else
                    statement2.setString(offset + 2, section);
                statement2.setString(offset + 3, cite.type());
                statement2.setInt(offset + 4, cite.year());
                statement2.setInt(offset + 5, cite.number());
                statement2.setString(offset + 6, cite.text());
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
