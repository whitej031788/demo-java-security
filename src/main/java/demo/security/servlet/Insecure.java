package demo.security.servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Random;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.databind.ObjectMapper;

public class Insecure {

  public void badFunction(HttpServletRequest request) throws IOException {
    String obj = request.getParameter("data");
    ObjectMapper mapper = new ObjectMapper();
    mapper.enableDefaultTyping();
    String val = mapper.readValue(obj, String.class);
    File tempDir;
    tempDir = File.createTempFile("", ".");
    tempDir.delete();
    tempDir.mkdir();
    String dontUse = "fontUset";
    Files.exists(Paths.get("/tmp/", obj));
  }

  public static String processLargeData(String data) {
    // Simulate a long and complex method
    StringBuilder resultBuilder = new StringBuilder();
    if (data != null) {
      String[] parts = data.split(",");
      for (String part : parts) {
        if (part.startsWith("A")) {
          String processedA = part.substring(1).trim().toUpperCase();
          resultBuilder.append("Processed A: ").append(processedA).append("\n");
          if (processedA.length() > 5) {
            resultBuilder.append("  - Lengthy A\n");
            if (processedA.contains("X")) {
              resultBuilder.append("    - Contains X\n");
            }
          }
        } else if (part.startsWith("B")) {
          String processedB = part.substring(1).trim().toLowerCase();
          resultBuilder.append("Processed B: ").append(processedB).append("\n");
          // More and more logic...
          if (processedB.length() > 3) {
            resultBuilder.append("  - Longer B\n");
            if (processedB.equals("test")) {
              resultBuilder.append("    - Is 'test'\n");
            }
          }
        } else {
          resultBuilder.append("Ignored: ").append(part).append("\n");
        }

        // Even more processing steps...
        if (part.length() % 2 == 0) {
          resultBuilder.append("  - Even length\n");
        } else {
          resultBuilder.append("  - Odd length\n");
        }
      }
    } else {
      resultBuilder.append("No data provided.\n");
    }
    return resultBuilder.toString();
  }

  // 2. Insecure Random Number Generation (Security)
  public static int generatePredictableId() {
    Random random = new Random(1); // Using a fixed seed
    return random.nextInt(1000);
  }

  public String taintedSQL(HttpServletRequest request, Connection connection) throws Exception {
    String user = request.getParameter("user");
    String query = "SELECT userid FROM users WHERE username = '" + user  + "'";
    Statement statement = connection.createStatement();
    ResultSet resultSet = statement.executeQuery(query);
    return resultSet.getString(0);
  }
  
  public String hotspotSQL(Connection connection, String user) throws Exception {
	  Statement statement = null;
	  statement = connection.createStatement();
	  ResultSet rs = statement.executeQuery("select userid from users WHERE username=" + user);
	  return rs.getString(0);
	}
  // --------------------------------------------------------------------------
  // Custom sources, sanitizer and sinks example
  // See file s3649JavaSqlInjectionConfig.json in root directory 
  // --------------------------------------------------------------------------

  public String getInput(String name) {
    // Empty (fake) source
    // To be a real source this should normally return something from an input
    // that can be user manipulated e.g. an HTTP request, a cmd line parameter, a form input...
    return "Hello World and " + name;
  }

  public void storeData(String input) {
    // Empty (fake) sink
    // To be a real sink this should normally build an SQL query from the input parameter
  }

  public void verifyData(String input) {
    // Empty (fake) sanitizer (sic)
    // To be a real sanitizer this should normally examine the input and sanitize it
    // for any attempt of user manipulation (eg escaping characters, quoting strings etc...)
  }

  public void processParam(String input) {
    // Empty method just for testing
  }

  public void doSomething() {
    String myInput = getInput("Olivier"); // Get data from a source
    processParam(myInput);
    storeData(myInput);                   // store data w/o sanitizing --> Injection vulnerability 
  }

  public void doSomethingSanitized() {
    String myInput = getInput("Cameron"); // Get data from a source
    verifyData(myInput);                  // Sanitize data
    processParam(myInput);
    storeData(myInput);                   // store data after sanitizing --> No injection vulnerability 
  }
}
