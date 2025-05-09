package demo.security.util;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;

public class WebhookUtils {

    private static final String SECRET_KEY = "hardcodedkey123"; // SonarQube violation: Hardcoded encryption key

    public String decryptPayload(String encryptedPayload) throws Exception {
        // SonarQube violation: Weak encryption algorithm (AES/ECB/PKCS5Padding)
        Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
        SecretKeySpec secretKey = new SecretKeySpec(SECRET_KEY.getBytes(), "AES");
        cipher.init(Cipher.DECRYPT_MODE, secretKey);
        byte[] decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(encryptedPayload));
        return new String(decryptedBytes);
    }

    public void processPayload(String payload) {
        // SonarQube violation: No sanitization of the payload
        System.out.println("Processing payload: " + payload);
    }

    public String extractData(String payload, String key) {
        // SonarQube violation: No validation or sanitization of input
        if (payload.contains(key)) {
            return payload.substring(payload.indexOf(key) + key.length());
        }
        return null;
    }

    public void logPayload(String payload) {
        // SonarQube violation: Logging sensitive data
        System.out.println("Received payload: " + payload);
    }
}