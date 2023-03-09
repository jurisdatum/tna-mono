package uk.gov.legislation.db2.rds;

import uk.gov.legislation.cites.Cite;
import uk.gov.legislation.cites.EmbeddedCite;

import java.sql.*;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;

public class Citations {

    public static void save(String id, List<EmbeddedCite> cites) throws SQLException {
        if (cites.isEmpty())
            return;
        String delete = "DELETE FROM citations WHERE id = ?";
        Connection connection = MySQL.getConnection();
        connection.setAutoCommit(false);
        try {
            PreparedStatement statement1 = connection.prepareStatement(delete);
            statement1.setString(1, id);
            statement1.executeUpdate();
            statement1.close();
            String add = "INSERT INTO citations (id, part, section, type, year, number, text) VALUES";
            ListIterator<EmbeddedCite> it = cites.listIterator();
            if (it.hasNext()) {
                it.next();
                add += " (?, ?, ?, ?, ?, ?, ?)";
            }
            while (it.hasNext()) {
                it.next();
                add += ", (?, ?, ?, ?, ?, ?, ?)";
            }
            PreparedStatement statement2 = connection.prepareStatement(add);
            it = cites.listIterator();
            while (it.hasNext()) {
                int i = it.nextIndex();
                EmbeddedCite embedded = it.next();
                EmbeddedCite.Part part = embedded.part();
                String section = embedded.section();
                Cite cite = embedded.cite();
                final int offset = i * 7;
                statement2.setString( offset + 1, id);
                if (part == null)
                    statement2.setNull(offset + 2, Types.VARCHAR);
                else
                    statement2.setString(offset + 2, part.name().toLowerCase());
                if (section == null)
                    statement2.setNull(offset + 3, Types.VARCHAR);
                else
                    statement2.setString(offset + 3, section);
                statement2.setString(offset + 4, cite.type());
                statement2.setInt(offset + 5, cite.year());
                statement2.setInt(offset + 6, cite.number());
                statement2.setString(offset + 7, cite.text());
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

    public static class FullCitation {

        public final String docId;
        public final EmbeddedCite cite;

        private FullCitation(ResultSet result) throws SQLException {
            docId = result.getString("id");
            EmbeddedCite.Part part;
            try {
                part = EmbeddedCite.Part.valueOf(result.getString("part"));
            } catch (Exception e) {
                part = null;
            }
            String section = result.getString("section");
            String type = result.getString("type");
            int year = result.getInt("year");
            int number = result.getInt("number");
            String text = result.getString("text");
            Cite cite1 = new Cite(text, type, year, number);
            cite = new EmbeddedCite(part, section, cite1);
        }

    }

    private static List<FullCitation> fetchTypeLike(Connection connection, String like, int limit, int offset) throws SQLException {
        List<FullCitation> list = new LinkedList<>();
        String sql = "SELECT * FROM citations WHERE type LIKE ? ORDER BY id LIMIT ?, ?;";
        PreparedStatement statement = connection.prepareStatement(sql);
        statement.setString(1, like);
        statement.setInt(2, offset);
        statement.setInt(3, limit);
        ResultSet result = statement.executeQuery();
        while (result.next()) {
            FullCitation x = new FullCitation(result);
            list.add(x);
        }
        result.close();
        statement.close();
        return list;
    }

    private static class CitationIterator implements Iterator<FullCitation> {

        private final Connection connection;
        private final String like;
        private final int batchSize = 1000;
        private int batch = 0;
        private ListIterator<FullCitation> iterator;

        private CitationIterator(String like) throws SQLException {
            this.connection = MySQL.getConnection();
            this.like = like;
            getIterator();
        }

        private void getIterator() {
            System.out.print("batch " + batch + ": ");
            try {
                List<FullCitation> list = fetchTypeLike(connection, like, batchSize, batch * batchSize);
                System.out.println(list.size() + " cites");
                iterator = list.listIterator();
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            batch += 1;
        }

        @Override
        public boolean hasNext() {
            if (iterator.hasNext())
                return true;
            getIterator();
            if (iterator.hasNext())
                return true;
            try {
                connection.close();
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            return false;
        }

        @Override
        public FullCitation next() {
            return iterator.next();
        }

    }

    public static Iterator<FullCitation> fetchAllToEU() throws SQLException {
        return new CitationIterator("European%");
    }

}
