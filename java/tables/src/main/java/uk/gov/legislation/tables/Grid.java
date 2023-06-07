package uk.gov.legislation.tables;

import java.util.ArrayList;
import java.util.List;

public class Grid {

    public static class Cell {

        private final String text;
        public String text() { return text; }

        private final boolean first;
        public boolean first() { return first; }

        private final int colspan, rowspan;
        public int colspan() { return colspan; }
        public int rowspan() { return rowspan; }

        @Override
        public String toString() {
            return text;
        }

        private Cell(String text, boolean first, int colspan, int rowspan) {
            this.text = text;
            this.first = first;
            this.colspan = colspan;
            this.rowspan = rowspan;
        }

    }

    public static List<List<Cell>> convert(HtmlTable html, boolean footer) {
        Grid grid = new Grid();
        grid.table(html, footer);
        return grid.cells;
    }

    private final List<List<Cell>> cells = new ArrayList<>();

    private void table(HtmlTable html, boolean footer) {
        for (HtmlTable.Row row : html.header())
            row(row);
        for (HtmlTable.Row row : html.body())
            row(row);
        if (!footer)
            return;
        for (HtmlTable.Row row : html.footer())
            row(row);
    }

    private int done = 0;

    private void row(HtmlTable.Row row) {
        for (HtmlTable.Cell cell : row.cells())
            cell(cell);
        done += 1;
    }

    private void cell(HtmlTable.Cell html) {
        Point point = getInsertionPoint();
        int colspan = html.colspan();
        int rowspan = html.rowspan();
        for (int i = 0; i < rowspan; i++) {
            for (int j = 0; j < colspan; j++) {
                boolean first = i == 0 && j == 0;
                String text = first ? html.toString() : null;
                Cell cell = new Cell(text, first, colspan, rowspan);
                addCell(point.row + i, point.col + j, cell);
            }
        }
    }

    private static class Point {
        private final int row, col;

        private Point(int row, int col) {
            this.row = row;
            this.col = col;
        }
    }

    private Point getInsertionPoint() {
        if (cells.size() == done)
            return new Point(done, 0);
        List<Cell> row = cells.get(done);
        int j = row.indexOf(null);
        if (j != -1)
            return new Point(done, j);
        return new Point(done, row.size());
    }

    private void addCell(int row, int col, Cell cell) {
        if (cells.size() < row)
            throw new IllegalArgumentException();
        if (cells.size() == row)
            cells.add(new ArrayList<>());
        List<Cell> x = cells.get(row);
        if (x.size() == col) {
            x.add(cell);
            return;
        }
        if (x.size() < col) {
            for (int j = x.size(); j < col; j++)
                x.add(null);
            x.add(cell);
            return;
        }
        if (x.get(col) != null)
            throw new IllegalStateException();
        x.set(col, cell);
    }

}
