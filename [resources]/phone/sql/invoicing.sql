DROP TABLE IF EXISTS `phone_invoices`;

CREATE TABLE `phone_invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `sender` varchar(50) NOT NULL,
  `job` varchar(45) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `amount` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;