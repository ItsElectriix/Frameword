CREATE TABLE `safes` (
  `citizenid` varchar(50) NOT NULL,
  `location` longtext NOT NULL,
  `safeid` varchar(100) NOT NULL,
  `pin` int NOT NULL DEFAULT '123456',
  `deleted` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/* Migration script

INSERT INTO safes SELECT citizenid, location, CONCAT(citizenid, safeid), pin, deleted FROM player_safes WHERE deleted = 0;
INSERT INTO stashitems (stash, items) SELECT CONCAT('safe_', citizenid, safeid), items FROM player_safes WHERE  deleted = 0 AND items != 'null' AND items != '[]';

*/