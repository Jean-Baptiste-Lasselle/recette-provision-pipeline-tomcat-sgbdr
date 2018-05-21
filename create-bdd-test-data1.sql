-- --------------------------------------------------------
-- Hôte :                        192.168.1.149
-- Version du serveur:           10.1.30-MariaDB-1~jessie - mariadb.org binary distribution
-- SE du serveur:                debian-linux-gnu
-- HeidiSQL Version:             9.5.0.5196
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Export de la structure de la base pour bdd_organisaction
-- DROP DATABASE IF EXISTS `bdd_organisaction`;
-- CREATE DATABASE IF NOT EXISTS `bdd_organisaction` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;
-- Jean-Baptiste Lasselle: la chaîne [VAL_NOM_BDD_APPLI] ci-dessous, est remplacée par la valeur effective du nom de la bdd, au cours des opérations, au provisionning de la cible de déploiement)
USE `VAL_NOM_BDD_APPLI`;

-- Export de la structure de la table bdd_organisaction. membresassoc
CREATE TABLE IF NOT EXISTS `membresassoc` (
  `prenom` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `idpk` bigint(20) NOT NULL AUTO_INCREMENT,
  `nom` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `username` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `email` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `age` int(11) NOT NULL DEFAULT '24',
  PRIMARY KEY (`idpk`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Export de données de la table bdd_organisaction.membresassoc : ~2 rows (environ)
/*!40000 ALTER TABLE `membresassoc` DISABLE KEYS */;
INSERT INTO `membresassoc` (`prenom`, `idpk`, `nom`, `username`, `email`, `age`) VALUES
	('John', 1, 'Malkovich', 'jimv', 'jivm@hugestarts.com', 23),
	('Johnny', 2, 'Depp', 'jde', 'jde-at-my@best.io', 23);
/*!40000 ALTER TABLE `membresassoc` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
