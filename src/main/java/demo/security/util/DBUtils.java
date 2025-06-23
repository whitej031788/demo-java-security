package demo.security.util;

import javax.servlet.http.HttpServletRequest;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DBUtils {

    Connection connection;
    public DBUtils() throws SQLException {
        connection = DriverManager.getConnection(
                "mYJDBCUrl", "myJDBCUser", "myJDBCPass");
    }

    public List<String> findUsers(String user) throws Exception {
        String query = "SELECT userid FROM users WHERE username = '" + user  + "'";
        Statement statement = connection.createStatement();
        ResultSet resultSet = statement.executeQuery(query);
        List<String> users = new ArrayList<String>();
        while (resultSet.next()){
            users.add(resultSet.getString(0));
        }
        return users;
    }

    public List<String> findItem(String itemId) throws Exception {
        String query = "SELECT item_id FROM items WHERE item_id = '" + itemId  + "'";
        Statement statement = connection.createStatement();
        ResultSet resultSet = statement.executeQuery(query);
        List<String> items = new ArrayList<String>();
        while (resultSet.next()){
            items.add(resultSet.getString(0));
        }
        return items;
    }

    public String getCustomerContactInfo(String customerName) {
        String query = "SELECT email, phone_number FROM customers WHERE customer_name = '" + customerName + "'";
        try (Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(query)) {
            if (resultSet.next()) {
                String email = resultSet.getString("email");
                String phoneNumber = resultSet.getString("phone_number");
                return email + " - " + phoneNumber;
            }
        } catch (Exception e) {
            e.printStackTrace(); // Log the exception for debugging
        }
        return null; // Return null if no contact info is found or an error occurs
    }
}
