# Root logger configuration
log4j.rootLogger=INFO, file

# File appender
log4j.appender.file=org.apache.log4j.FileAppender
log4j.appender.file.File=app.log
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n



import org.apache.log4j.Logger;

public class Main {
    private static final Logger logger = Logger.getLogger(Main.class);

    public static void main(String[] args) {
        logger.info("Application started.");

        DatabaseHandler dbHandler = new DatabaseHandler();

        // Using File-based database
        dbHandler.useFileBasedDb();

        // Using MSSQL database
        dbHandler.useMssql();

        logger.info("Application ended.");
    }
}





import org.apache.log4j.Logger;

import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class DatabaseHandler {
    private static final Logger logger = Logger.getLogger(DatabaseHandler.class);

    public void useFileBasedDb() {
        logger.info("Using file-based database.");
        try (FileWriter writer = new FileWriter("filedb.txt", true)) {
            writer.write("Sample data written to file-based database.\n");
            logger.info("Data written successfully to file-based database.");
        } catch (IOException e) {
            logger.error("Error writing to file-based database.", e);
        }
    }

    public void useMssql() {
        logger.info("Using MSSQL database.");
        String url = "jdbc:sqlserver://localhost:1433;databaseName=TestDb";
        String user = "your_username";
        String password = "your_password";

        try (Connection connection = DriverManager.getConnection(url, user, password);
             Statement statement = connection.createStatement()) {
            String sql = "CREATE TABLE IF NOT EXISTS TestTable (id INT PRIMARY KEY, name NVARCHAR(50))";
            statement.execute(sql);
            logger.info("Table created successfully in MSSQL database.");
        } catch (SQLException e) {
            logger.error("Error interacting with MSSQL database.", e);
        }
    }
}
