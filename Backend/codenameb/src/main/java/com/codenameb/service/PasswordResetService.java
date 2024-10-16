package com.codenameb.service;

import com.codenameb.model.User;
import com.codenameb.model.authentication.PasswordResetToken;
import com.codenameb.repository.PasswordResetTokenRepository;
import com.codenameb.repository.UserRepository;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PasswordResetService {
	private final UserRepository userRepository;
	private final PasswordResetTokenRepository passwordResetTokenRepository;
	private final PasswordEncoder passwordEncoder;
	private final JavaMailSender mailSender;

	@Value("${spring.mail.from}")
	private String fromAddress;

	public void generatePasswordResetToken(String email) {
		User user = userRepository.findByEmail(email)
			.orElseThrow(() -> new IllegalArgumentException("User not found with email: " + email));

		String token = UUID.randomUUID().toString();
		PasswordResetToken passwordResetToken = new PasswordResetToken(token, user, LocalDateTime.now().plusHours(1));
		passwordResetTokenRepository.save(passwordResetToken);

		String resetLink = "http://localhost:4200/reset-password?token=" + token;
		sendResetEmail(user.getEmail(), resetLink);
	}

	private void sendResetEmail(String email, String resetLink) {
		SimpleMailMessage mailMessage = new SimpleMailMessage();
		mailMessage.setTo(email);
		mailMessage.setFrom(fromAddress); // Set the from address
		mailMessage.setSubject("Password Reset Request");
		mailMessage.setText("To reset your password, click the link below:\n" + resetLink);

		mailSender.send(mailMessage);
	}

	public void resetPassword(String token, String newPassword) {
		PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(token)
			.orElseThrow(() -> new IllegalArgumentException("Invalid password reset token"));

		if (resetToken.isExpired()) {
			throw new IllegalArgumentException("Token has expired");
		}

		User user = resetToken.getUser();
		user.setPassword(passwordEncoder.encode(newPassword));
		userRepository.save(user);
		passwordResetTokenRepository.delete(resetToken);
	}
}
