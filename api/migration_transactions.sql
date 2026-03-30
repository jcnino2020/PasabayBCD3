-- ============================================================
-- Migration: Create pasabaybcd_transactions table
-- Run this once on your MySQL server to enable the wallet
-- transactions feature in the app.
-- ============================================================

CREATE TABLE IF NOT EXISTS `pasabaybcd_transactions` (
  `id`         INT(11)        NOT NULL AUTO_INCREMENT,
  `user_id`    INT(11)        NOT NULL,
  `label`      VARCHAR(255)   NOT NULL,
  `amount`     DECIMAL(10,2)  NOT NULL COMMENT 'Positive = top-up, Negative = expense',
  `created_at` TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_tx_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `pasabaybcd_users` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Optional: seed sample data for user_id = 1 to verify it works
-- INSERT INTO `pasabaybcd_transactions` (user_id, label, amount) VALUES
-- (1, 'Top Up via GCash', 500.00),
-- (1, 'Trip: Juan Dela Cruz', -150.00),
-- (1, 'Top Up via Maya', 200.00);
