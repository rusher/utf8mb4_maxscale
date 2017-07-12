package org.mariadb.maxscale;

import org.junit.Assert;
import org.junit.Assume;

import java.io.*;
import java.sql.*;
import java.util.Arrays;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

/**
 * Created by diego on 12/07/2017.
 */
public class Test {

    private Connection getConnection() throws SQLException {
        String port = System.getenv("MAXSCALE_VERSION") == null ? "3305" : "4007";
        return DriverManager.getConnection("jdbc:mariadb://localhost:" + port + "/testj?user=bob&killFetchStmtOnClose=false&enablePacketDebug=true");
    }

    @org.junit.Test
    public void emoji() throws SQLException {

        try (Connection connection = getConnection()) {
            String sqlForCharset = "select @@character_set_server";
            ResultSet rs = connection.createStatement().executeQuery(sqlForCharset);
            Assert.assertTrue(rs.next());
            final String serverCharacterSet = rs.getString(1);
            sqlForCharset = "select @@character_set_client";
            rs = connection.createStatement().executeQuery(sqlForCharset);
            Assert.assertTrue(rs.next());
            String clientCharacterSet = rs.getString(1);

            Assert.assertEquals(serverCharacterSet, clientCharacterSet);

            Statement stmt = connection.createStatement();
            stmt.execute("DROP TABLE IF EXISTS emojiTest");
            stmt.execute("CREATE TABLE emojiTest(id int unsigned, field longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci)");
            PreparedStatement ps = connection.prepareStatement("INSERT INTO emojiTest (id, field) VALUES (1, ?)");
            byte[] emoji = new byte[]{(byte) 0xF0, (byte) 0x9F, (byte) 0x98, (byte) 0x84};
            ps.setBytes(1, emoji);
            ps.execute();
            ps = connection.prepareStatement("SELECT field FROM emojiTest");
            rs = ps.executeQuery();
            Assert.assertTrue(rs.next());
            // compare to the Java representation of UTF32
            Assert.assertEquals("\uD83D\uDE04", rs.getString(1));
        }
    }

    @org.junit.Test
    public void test4BytesUtf8() throws Exception {

        String sqlForCharset = "select @@character_set_server";
        try (Connection connection = getConnection()) {


            Statement stmt = connection.createStatement();
            stmt.execute("DROP TABLE IF EXISTS unicodeTestChar");
            stmt.execute("CREATE TABLE unicodeTestChar(id int unsigned, field1 varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci, field2 longtext "
                    + "CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci) DEFAULT CHARSET=utf8mb4");


            ResultSet rs = connection.createStatement().executeQuery(sqlForCharset);
            if (rs.next()) {
                String emoji = "\uD83C\uDF1F";
                boolean mustThrowError = true;

                PreparedStatement ps = connection.prepareStatement("INSERT INTO unicodeTestChar (id, field1, field2) VALUES (1, ?, ?)");
                ps.setString(1, emoji);
                Reader reader = new StringReader(emoji);
                ps.setCharacterStream(2, reader);

                ps.execute();
                ps = connection.prepareStatement("SELECT field1, field2 FROM unicodeTestChar");
                rs = ps.executeQuery();
                assertTrue(rs.next());

                // compare to the Java representation of UTF32
                assertEquals(4, rs.getBytes(1).length);
                assertEquals(emoji, rs.getString(1));

                assertEquals(4, rs.getBytes(2).length);
                assertEquals(emoji, rs.getString(2));
            } else {
                fail();
            }
        }
    }

    @org.junit.Test
    public void binTest2() throws SQLException, IOException {

        for (int b = 0; b < 256; b ++) {
            byte[] buf = new byte[100000];
            Arrays.fill(buf, (byte) b);
            InputStream is = new ByteArrayInputStream(buf);

            try (Connection connection = getConnection()) {
                Statement stmt = connection.createStatement();
                stmt.execute("DROP TABLE IF EXISTS bintest4");
                stmt.execute("CREATE TABLE bintest4(bin1 longblob)");
                try (PreparedStatement ps = connection.prepareStatement("insert into bintest4 (bin1) values (?)")) {
                    ps.setBinaryStream(1, is);
                    ps.execute();
                }

                ResultSet rs = stmt.executeQuery("select bin1 from bintest4");
                assertTrue(rs.next());
                byte[] buf2 = rs.getBytes(1);
                assertEquals(100000, buf2.length);
                for (int i = 0; i < 100000; i++) {
                    assertEquals(buf[i], buf2[i]);
                }
            } catch (Exception e) {
                System.err.println("ERROR with byte " + b);
                throw e;
            }
        }
    }
}
