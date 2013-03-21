--
-- Current Database: `r_nova`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `r_nova` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `r_nova`;

--
-- Table structure for table `agent_builds`
--

DROP TABLE IF EXISTS `agent_builds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agent_builds` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hypervisor` varchar(255) DEFAULT NULL,
  `os` varchar(255) DEFAULT NULL,
  `architecture` varchar(255) DEFAULT NULL,
  `version` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `md5hash` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `agent_builds_hypervisor_os_arch_idx` (`hypervisor`,`os`,`architecture`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aggregate_hosts`
--

DROP TABLE IF EXISTS `aggregate_hosts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregate_hosts` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) DEFAULT NULL,
  `aggregate_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `aggregate_id` (`aggregate_id`),
  CONSTRAINT `aggregate_hosts_ibfk_1` FOREIGN KEY (`aggregate_id`) REFERENCES `aggregates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aggregate_metadata`
--

DROP TABLE IF EXISTS `aggregate_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregate_metadata` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `aggregate_id` int(11) NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `aggregate_id` (`aggregate_id`),
  KEY `aggregate_metadata_key_idx` (`key`),
  CONSTRAINT `aggregate_metadata_ibfk_1` FOREIGN KEY (`aggregate_id`) REFERENCES `aggregates` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aggregates`
--

DROP TABLE IF EXISTS `aggregates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aggregates` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `availability_zone` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `block_device_mapping`
--

DROP TABLE IF EXISTS `block_device_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `block_device_mapping` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `device_name` varchar(255) NOT NULL,
  `delete_on_termination` tinyint(1) DEFAULT NULL,
  `virtual_name` varchar(255) DEFAULT NULL,
  `snapshot_id` varchar(36) DEFAULT NULL,
  `volume_id` varchar(36) DEFAULT NULL,
  `volume_size` int(11) DEFAULT NULL,
  `no_device` tinyint(1) DEFAULT NULL,
  `connection_info` text,
  `instance_uuid` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `snapshot_id` (`snapshot_id`),
  KEY `volume_id` (`volume_id`),
  KEY `block_device_mapping_instance_uuid_idx` (`instance_uuid`),
  KEY `block_device_mapping_instance_uuid_device_name_idx` (`instance_uuid`,`device_name`),
  KEY `block_device_mapping_instance_uuid_virtual_name_device_name_idx` (`instance_uuid`,`virtual_name`,`device_name`),
  KEY `block_device_mapping_instance_uuid_volume_id_idx` (`instance_uuid`,`volume_id`),
  CONSTRAINT `block_device_mapping_instance_uuid_fkey` FOREIGN KEY (`instance_uuid`) REFERENCES `instances` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bw_usage_cache`
--

DROP TABLE IF EXISTS `bw_usage_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bw_usage_cache` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_period` datetime NOT NULL,
  `last_refreshed` datetime DEFAULT NULL,
  `bw_in` bigint(20) DEFAULT NULL,
  `bw_out` bigint(20) DEFAULT NULL,
  `mac` varchar(255) DEFAULT NULL,
  `uuid` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bw_usage_cache_uuid_start_period_idx` (`uuid`,`start_period`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cells`
--

DROP TABLE IF EXISTS `cells`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cells` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `api_url` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `weight_offset` float DEFAULT NULL,
  `weight_scale` float DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `is_parent` tinyint(1) DEFAULT NULL,
  `rpc_host` varchar(255) DEFAULT NULL,
  `rpc_port` int(11) DEFAULT NULL,
  `rpc_virtual_host` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `certificates`
--

DROP TABLE IF EXISTS `certificates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `certificates` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `certificates_project_id_deleted_idx` (`project_id`,`deleted`),
  KEY `certificates_user_id_deleted_idx` (`user_id`,`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `compute_node_stats`
--

DROP TABLE IF EXISTS `compute_node_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compute_node_stats` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `compute_node_id` int(11) NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_compute_node_stats_compute_node_id` (`compute_node_id`)
) ENGINE=InnoDB AUTO_INCREMENT=144 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `compute_nodes`
--

DROP TABLE IF EXISTS `compute_nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compute_nodes` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_id` int(11) NOT NULL,
  `vcpus` int(11) NOT NULL,
  `memory_mb` int(11) NOT NULL,
  `local_gb` int(11) NOT NULL,
  `vcpus_used` int(11) NOT NULL,
  `memory_mb_used` int(11) NOT NULL,
  `local_gb_used` int(11) NOT NULL,
  `hypervisor_type` text NOT NULL,
  `hypervisor_version` int(11) NOT NULL,
  `cpu_info` text NOT NULL,
  `disk_available_least` int(11) DEFAULT NULL,
  `free_ram_mb` int(11) DEFAULT NULL,
  `free_disk_gb` int(11) DEFAULT NULL,
  `current_workload` int(11) DEFAULT NULL,
  `running_vms` int(11) DEFAULT NULL,
  `hypervisor_hostname` varchar(255) DEFAULT NULL,
  `private_network_mbps_used` int(11) DEFAULT NULL,
  `public_network_mbps_used` int(11) DEFAULT NULL,
  `total_private_network_mbps` int(11) DEFAULT NULL,
  `total_public_network_mbps` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `console_pools`
--

DROP TABLE IF EXISTS `console_pools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `console_pools` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `console_type` varchar(255) DEFAULT NULL,
  `public_hostname` varchar(255) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `compute_host` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `consoles`
--

DROP TABLE IF EXISTS `consoles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `consoles` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_name` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `pool_id` int(11) DEFAULT NULL,
  `instance_uuid` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pool_id` (`pool_id`),
  KEY `consoles_instance_uuid_idx` (`instance_uuid`),
  CONSTRAINT `consoles_instance_uuid_fkey` FOREIGN KEY (`instance_uuid`) REFERENCES `instances` (`uuid`),
  CONSTRAINT `consoles_ibfk_1` FOREIGN KEY (`pool_id`) REFERENCES `console_pools` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dns_domains`
--

DROP TABLE IF EXISTS `dns_domains`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dns_domains` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `domain` varchar(255) NOT NULL,
  `scope` varchar(255) DEFAULT NULL,
  `availability_zone` varchar(255) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`domain`),
  KEY `project_id` (`project_id`),
  KEY `dns_domains_domain_deleted_idx` (`domain`,`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fixed_ips`
--

DROP TABLE IF EXISTS `fixed_ips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fixed_ips` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `network_id` int(11) DEFAULT NULL,
  `allocated` tinyint(1) DEFAULT NULL,
  `leased` tinyint(1) DEFAULT NULL,
  `reserved` tinyint(1) DEFAULT NULL,
  `virtual_interface_id` int(11) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `instance_uuid` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fixed_ips_virtual_interface_id_fkey` (`virtual_interface_id`),
  KEY `address` (`address`),
  KEY `fixed_ips_instance_uuid_fkey` (`instance_uuid`),
  KEY `fixed_ips_host_idx` (`host`),
  KEY `fixed_ips_network_id_host_deleted_idx` (`network_id`,`host`,`deleted`),
  KEY `fixed_ips_address_reserved_network_id_deleted_idx` (`address`,`reserved`,`network_id`,`deleted`),
  CONSTRAINT `fixed_ips_instance_uuid_fkey` FOREIGN KEY (`instance_uuid`) REFERENCES `instances` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=513 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `floating_ips`
--

DROP TABLE IF EXISTS `floating_ips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `floating_ips` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `fixed_ip_id` int(11) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `auto_assigned` tinyint(1) DEFAULT NULL,
  `pool` varchar(255) DEFAULT NULL,
  `interface` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fixed_ip_id` (`fixed_ip_id`),
  KEY `floating_ips_host_idx` (`host`),
  KEY `floating_ips_project_id_idx` (`project_id`),
  KEY `floating_ips_pool_deleted_fixed_ip_id_project_id_idx` (`pool`,`deleted`,`fixed_ip_id`,`project_id`)
) ENGINE=InnoDB AUTO_INCREMENT=765 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_faults`
--

DROP TABLE IF EXISTS `instance_faults`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_faults` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_uuid` varchar(36) DEFAULT NULL,
  `code` int(11) NOT NULL,
  `message` varchar(255) DEFAULT NULL,
  `details` text,
  PRIMARY KEY (`id`),
  KEY `instance_faults_instance_uuid_deleted_created_at_idx` (`instance_uuid`,`deleted`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_id_mappings`
--

DROP TABLE IF EXISTS `instance_id_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_id_mappings` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_instance_id_mappings_uuid` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_info_caches`
--

DROP TABLE IF EXISTS `instance_info_caches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_info_caches` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `network_info` text,
  `instance_uuid` varchar(36) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `instance_id` (`instance_uuid`),
  CONSTRAINT `instance_info_caches_instance_uuid_fkey` FOREIGN KEY (`instance_uuid`) REFERENCES `instances` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_metadata`
--

DROP TABLE IF EXISTS `instance_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_metadata` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `instance_uuid` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `instance_metadata_instance_uuid_idx` (`instance_uuid`),
  CONSTRAINT `instance_metadata_instance_uuid_fkey` FOREIGN KEY (`instance_uuid`) REFERENCES `instances` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_system_metadata`
--

DROP TABLE IF EXISTS `instance_system_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_system_metadata` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_uuid` varchar(36) NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_system_metadata_extension`
--

DROP TABLE IF EXISTS `instance_system_metadata_extension`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_system_metadata_extension` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_uuid` varchar(36) NOT NULL,
  `key` varchar(255) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_type_extra_specs`
--

DROP TABLE IF EXISTS `instance_type_extra_specs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_type_extra_specs` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_type_id` int(11) NOT NULL,
  `key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `instance_type_extra_specs_instance_type_id_key_idx` (`instance_type_id`,`key`),
  CONSTRAINT `instance_type_extra_specs_ibfk_1` FOREIGN KEY (`instance_type_id`) REFERENCES `instance_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_type_projects`
--

DROP TABLE IF EXISTS `instance_type_projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_type_projects` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `instance_type_id` int(11) NOT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `instance_type_id` (`instance_type_id`),
  CONSTRAINT `instance_type_projects_ibfk_1` FOREIGN KEY (`instance_type_id`) REFERENCES `instance_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instance_types`
--

DROP TABLE IF EXISTS `instance_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instance_types` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `memory_mb` int(11) NOT NULL,
  `vcpus` int(11) NOT NULL,
  `swap` int(11) NOT NULL,
  `vcpu_weight` int(11) DEFAULT NULL,
  `flavorid` varchar(255) DEFAULT NULL,
  `rxtx_factor` float DEFAULT NULL,
  `root_gb` int(11) DEFAULT NULL,
  `ephemeral_gb` int(11) DEFAULT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instances`
--

DROP TABLE IF EXISTS `instances`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instances` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `internal_id` int(11) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  `image_ref` varchar(255) DEFAULT NULL,
  `kernel_id` varchar(255) DEFAULT NULL,
  `ramdisk_id` varchar(255) DEFAULT NULL,
  `server_name` varchar(255) DEFAULT NULL,
  `launch_index` int(11) DEFAULT NULL,
  `key_name` varchar(255) DEFAULT NULL,
  `key_data` text,
  `power_state` int(11) DEFAULT NULL,
  `vm_state` varchar(255) DEFAULT NULL,
  `memory_mb` int(11) DEFAULT NULL,
  `vcpus` int(11) DEFAULT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `user_data` text,
  `reservation_id` varchar(255) DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `launched_at` datetime DEFAULT NULL,
  `terminated_at` datetime DEFAULT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `display_description` varchar(255) DEFAULT NULL,
  `availability_zone` varchar(255) DEFAULT NULL,
  `locked` tinyint(1) DEFAULT NULL,
  `os_type` varchar(255) DEFAULT NULL,
  `launched_on` text,
  `instance_type_id` int(11) DEFAULT NULL,
  `vm_mode` varchar(255) DEFAULT NULL,
  `uuid` varchar(36) DEFAULT NULL,
  `architecture` varchar(255) DEFAULT NULL,
  `root_device_name` varchar(255) DEFAULT NULL,
  `access_ip_v4` varchar(255) DEFAULT NULL,
  `access_ip_v6` varchar(255) DEFAULT NULL,
  `config_drive` varchar(255) DEFAULT NULL,
  `task_state` varchar(255) DEFAULT NULL,
  `default_ephemeral_device` varchar(255) DEFAULT NULL,
  `default_swap_device` varchar(255) DEFAULT NULL,
  `progress` int(11) DEFAULT NULL,
  `auto_disk_config` tinyint(1) DEFAULT NULL,
  `shutdown_terminate` tinyint(1) DEFAULT NULL,
  `disable_terminate` tinyint(1) DEFAULT NULL,
  `root_gb` int(11) DEFAULT NULL,
  `ephemeral_gb` int(11) DEFAULT NULL,
  `cell_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  KEY `project_id` (`project_id`),
  KEY `instances_host_deleted_idx` (`host`,`deleted`),
  KEY `instances_reservation_id_idx` (`reservation_id`),
  KEY `instances_terminated_at_launched_at_idx` (`terminated_at`,`launched_at`),
  KEY `instances_uuid_deleted_idx` (`uuid`,`deleted`),
  KEY `instances_task_state_updated_at_idx` (`task_state`,`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iscsi_targets`
--

DROP TABLE IF EXISTS `iscsi_targets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iscsi_targets` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_num` int(11) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `volume_id` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `iscsi_targets_volume_id_fkey` (`volume_id`),
  KEY `iscsi_targets_host_idx` (`host`),
  KEY `iscsi_targets_host_volume_id_deleted_idx` (`host`,`volume_id`,`deleted`),
  CONSTRAINT `iscsi_targets_volume_id_fkey` FOREIGN KEY (`volume_id`) REFERENCES `volumes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `key_pairs`
--

DROP TABLE IF EXISTS `key_pairs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `key_pairs` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `fingerprint` varchar(255) DEFAULT NULL,
  `public_key` text,
  `private_key_url` text,
  PRIMARY KEY (`id`),
  KEY `key_pair_user_id_name_idx` (`user_id`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
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

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_compute` varchar(255) DEFAULT NULL,
  `dest_compute` varchar(255) DEFAULT NULL,
  `dest_host` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `instance_uuid` varchar(255) DEFAULT NULL,
  `old_instance_type_id` int(11) DEFAULT NULL,
  `new_instance_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `networks`
--

DROP TABLE IF EXISTS `networks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `networks` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `injected` tinyint(1) DEFAULT NULL,
  `cidr` varchar(255) DEFAULT NULL,
  `netmask` varchar(255) DEFAULT NULL,
  `bridge` varchar(255) DEFAULT NULL,
  `gateway` varchar(255) DEFAULT NULL,
  `broadcast` varchar(255) DEFAULT NULL,
  `dns1` varchar(255) DEFAULT NULL,
  `vlan` int(11) DEFAULT NULL,
  `vpn_public_address` varchar(255) DEFAULT NULL,
  `vpn_public_port` int(11) DEFAULT NULL,
  `vpn_private_address` varchar(255) DEFAULT NULL,
  `dhcp_start` varchar(255) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `cidr_v6` varchar(255) DEFAULT NULL,
  `gateway_v6` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `netmask_v6` varchar(255) DEFAULT NULL,
  `bridge_interface` varchar(255) DEFAULT NULL,
  `multi_host` tinyint(1) DEFAULT NULL,
  `dns2` varchar(255) DEFAULT NULL,
  `uuid` varchar(36) DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `rxtx_base` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `networks_bridge_deleted_idx` (`bridge`,`deleted`),
  KEY `networks_host_idx` (`host`),
  KEY `networks_project_id_deleted_idx` (`project_id`,`deleted`),
  KEY `networks_uuid_project_id_deleted_idx` (`uuid`,`project_id`,`deleted`),
  KEY `networks_vlan_deleted_idx` (`vlan`,`deleted`),
  KEY `networks_cidr_v6_idx` (`cidr_v6`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provider_fw_rules`
--

DROP TABLE IF EXISTS `provider_fw_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provider_fw_rules` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `protocol` varchar(5) DEFAULT NULL,
  `from_port` int(11) DEFAULT NULL,
  `to_port` int(11) DEFAULT NULL,
  `cidr` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quota_classes`
--

DROP TABLE IF EXISTS `quota_classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quota_classes` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_name` varchar(255) DEFAULT NULL,
  `resource` varchar(255) DEFAULT NULL,
  `hard_limit` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_quota_classes_class_name` (`class_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quota_usages`
--

DROP TABLE IF EXISTS `quota_usages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quota_usages` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` varchar(255) DEFAULT NULL,
  `resource` varchar(255) DEFAULT NULL,
  `in_use` int(11) NOT NULL,
  `reserved` int(11) NOT NULL,
  `until_refresh` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_quota_usages_project_id` (`project_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quotas`
--

DROP TABLE IF EXISTS `quotas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `quotas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  `resource` varchar(255) NOT NULL,
  `hard_limit` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reservations` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  `usage_id` int(11) NOT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  `resource` varchar(255) DEFAULT NULL,
  `delta` int(11) NOT NULL,
  `expire` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usage_id` (`usage_id`),
  KEY `ix_reservations_project_id` (`project_id`),
  CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`usage_id`) REFERENCES `quota_usages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=189 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `s3_images`
--

DROP TABLE IF EXISTS `s3_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `s3_images` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `security_group_instance_association`
--

DROP TABLE IF EXISTS `security_group_instance_association`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `security_group_instance_association` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `security_group_id` int(11) DEFAULT NULL,
  `instance_uuid` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `security_group_id` (`security_group_id`),
  KEY `security_group_instance_association_instance_uuid_idx` (`instance_uuid`),
  CONSTRAINT `security_group_instance_association_instance_uuid_fkey` FOREIGN KEY (`instance_uuid`) REFERENCES `instances` (`uuid`),
  CONSTRAINT `security_group_instance_association_ibfk_1` FOREIGN KEY (`security_group_id`) REFERENCES `security_groups` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `security_group_rules`
--

DROP TABLE IF EXISTS `security_group_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `security_group_rules` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_group_id` int(11) DEFAULT NULL,
  `protocol` varchar(255) DEFAULT NULL,
  `from_port` int(11) DEFAULT NULL,
  `to_port` int(11) DEFAULT NULL,
  `cidr` varchar(255) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_group_id` (`parent_group_id`),
  KEY `group_id` (`group_id`),
  CONSTRAINT `security_group_rules_ibfk_1` FOREIGN KEY (`parent_group_id`) REFERENCES `security_groups` (`id`),
  CONSTRAINT `security_group_rules_ibfk_2` FOREIGN KEY (`group_id`) REFERENCES `security_groups` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `security_groups`
--

DROP TABLE IF EXISTS `security_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `security_groups` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) DEFAULT NULL,
  `host_ip` varchar(255) DEFAULT NULL,
  `binary` varchar(255) DEFAULT NULL,
  `topic` varchar(255) DEFAULT NULL,
  `report_count` int(11) NOT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  `availability_zone` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sm_backend_config`
--

DROP TABLE IF EXISTS `sm_backend_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sm_backend_config` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `flavor_id` int(11) NOT NULL,
  `sr_uuid` varchar(255) DEFAULT NULL,
  `sr_type` varchar(255) DEFAULT NULL,
  `config_params` varchar(2047) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `flavor_id` (`flavor_id`),
  CONSTRAINT `sm_backend_config_ibfk_1` FOREIGN KEY (`flavor_id`) REFERENCES `sm_flavors` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sm_flavors`
--

DROP TABLE IF EXISTS `sm_flavors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sm_flavors` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sm_volume`
--

DROP TABLE IF EXISTS `sm_volume`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sm_volume` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` varchar(36) NOT NULL,
  `backend_id` int(11) NOT NULL,
  `vdi_uuid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `backend_id` (`backend_id`),
  CONSTRAINT `sm_volume_id_fkey` FOREIGN KEY (`id`) REFERENCES `volumes` (`id`),
  CONSTRAINT `sm_volume_ibfk_2` FOREIGN KEY (`backend_id`) REFERENCES `sm_backend_config` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snapshot_id_mappings`
--

DROP TABLE IF EXISTS `snapshot_id_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snapshot_id_mappings` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `snapshots`
--

DROP TABLE IF EXISTS `snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `snapshots` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` varchar(36) NOT NULL,
  `volume_id` varchar(36) NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `progress` varchar(255) DEFAULT NULL,
  `volume_size` int(11) DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `display_description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `task_log`
--

DROP TABLE IF EXISTS `task_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_log` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_name` varchar(255) NOT NULL,
  `state` varchar(255) NOT NULL,
  `host` varchar(255) NOT NULL,
  `period_beginning` varchar(255) NOT NULL,
  `period_ending` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL,
  `task_items` int(11) DEFAULT NULL,
  `errors` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_task_log_host` (`host`),
  KEY `ix_task_log_period_beginning` (`period_beginning`),
  KEY `ix_task_log_period_ending` (`period_ending`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `virtual_interfaces`
--

DROP TABLE IF EXISTS `virtual_interfaces`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_interfaces` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `network_id` int(11) DEFAULT NULL,
  `uuid` varchar(36) DEFAULT NULL,
  `instance_uuid` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `address` (`address`),
  KEY `network_id` (`network_id`),
  KEY `virtual_interfaces_instance_uuid_fkey` (`instance_uuid`),
  CONSTRAINT `virtual_interfaces_instance_uuid_fkey` FOREIGN KEY (`instance_uuid`) REFERENCES `instances` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `virtual_storage_arrays`
--

DROP TABLE IF EXISTS `virtual_storage_arrays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `virtual_storage_arrays` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `display_name` varchar(255) DEFAULT NULL,
  `display_description` varchar(255) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  `availability_zone` varchar(255) DEFAULT NULL,
  `instance_type_id` int(11) NOT NULL,
  `image_ref` varchar(255) DEFAULT NULL,
  `vc_count` int(11) NOT NULL,
  `vol_count` int(11) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `volume_id_mappings`
--

DROP TABLE IF EXISTS `volume_id_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `volume_id_mappings` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` varchar(36) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `volume_metadata`
--

DROP TABLE IF EXISTS `volume_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `volume_metadata` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `volume_id` varchar(36) NOT NULL,
  `key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `volume_metadata_volume_id_fkey` (`volume_id`),
  CONSTRAINT `volume_metadata_volume_id_fkey` FOREIGN KEY (`volume_id`) REFERENCES `volumes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `volume_type_extra_specs`
--

DROP TABLE IF EXISTS `volume_type_extra_specs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `volume_type_extra_specs` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `volume_type_id` int(11) NOT NULL,
  `key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `volume_type_id` (`volume_type_id`),
  CONSTRAINT `volume_type_extra_specs_ibfk_1` FOREIGN KEY (`volume_type_id`) REFERENCES `volume_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `volume_types`
--

DROP TABLE IF EXISTS `volume_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `volume_types` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `volumes`
--

DROP TABLE IF EXISTS `volumes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `volumes` (
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  `id` varchar(36) NOT NULL,
  `ec2_id` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `project_id` varchar(255) DEFAULT NULL,
  `host` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `availability_zone` varchar(255) DEFAULT NULL,
  `mountpoint` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `attach_status` varchar(255) DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `launched_at` datetime DEFAULT NULL,
  `terminated_at` datetime DEFAULT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `display_description` varchar(255) DEFAULT NULL,
  `provider_location` varchar(256) DEFAULT NULL,
  `provider_auth` varchar(256) DEFAULT NULL,
  `snapshot_id` varchar(36) DEFAULT NULL,
  `volume_type_id` int(11) DEFAULT NULL,
  `instance_uuid` varchar(36) DEFAULT NULL,
  `attach_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `volumes_instance_uuid_idx` (`instance_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;