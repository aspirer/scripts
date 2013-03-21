--
-- Current Database: `r_glance`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `r_glance` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `r_glance`;

--
-- Table structure for table `cached_images`
--

DROP TABLE IF EXISTS `cached_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cached_images` (
  `image_id` varchar(64) NOT NULL,
  `last_accessed` float DEFAULT NULL,
  `last_modified` float DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `hits` int(11) DEFAULT NULL,
  `checksum` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`image_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image_members`
--

DROP TABLE IF EXISTS `image_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_members` (
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_id` varchar(36) NOT NULL,
  `member` varchar(255) NOT NULL,
  `can_share` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `image_id` (`image_id`,`member`) USING BTREE,
  CONSTRAINT `image_members_ibfk_1` FOREIGN KEY (`image_id`) REFERENCES `images` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image_properties`
--

DROP TABLE IF EXISTS `image_properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_properties` (
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_id` varchar(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `value` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `image_id` (`image_id`,`name`) USING BTREE,
  CONSTRAINT `image_properties_ibfk_1` FOREIGN KEY (`image_id`) REFERENCES `images` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1269 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image_tags`
--

DROP TABLE IF EXISTS `image_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_id` varchar(36) NOT NULL,
  `value` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_image_tags_image_id` (`image_id`),
  KEY `ix_image_tags_image_id_tag_value` (`image_id`,`value`),
  CONSTRAINT `image_tags_ibfk_1` FOREIGN KEY (`image_id`) REFERENCES `images` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL,
  `id` varchar(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `disk_format` varchar(20) DEFAULT NULL,
  `container_format` varchar(20) DEFAULT NULL,
  `size` bigint(20) DEFAULT NULL,
  `status` varchar(30) NOT NULL,
  `is_public` tinyint(1) NOT NULL,
  `location` text,
  `checksum` varchar(32) DEFAULT NULL,
  `min_disk` int(11) NOT NULL,
  `min_ram` int(11) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `protected` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migrate_version`
--

DROP TABLE IF EXISTS `migrate_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrate_version` (
  `repository_id` varchar(250) NOT NULL,
  `repository_path` text,
  `version` int(11) DEFAULT NULL,
  PRIMARY KEY (`repository_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;