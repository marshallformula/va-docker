CREATE DATABASE IF NOT EXISTS volume_users;

USE volume_users;

CREATE TABLE applications (
  app_id BIGINT NOT NULL AUTO_INCREMENT,
  app_name VARCHAR(64) NOT NULL, 
  app_label VARCHAR(64) NOT NULL,
  PRIMARY KEY (app_id),
  UNIQUE KEY (app_name)
);

CREATE TABLE clients (
  app_id BIGINT NOT NULL,
  client_id VARCHAR(64) NOT NULL,
  client_secret VARCHAR(64) NOT NULL,
  enabled TINYINT NOT NULL DEFAULT 1,
  expire_date TIMESTAMP,
  redirect_urls VARCHAR(1024),
  authorities VARCHAR(1024) DEFAULT 'ROLE_CLIENT',
  scopes VARCHAR(1024) DEFAULT 'permissions',
  auto_approve_scopes VARCHAR(1024) DEFAULT 'permissions',
  grant_types VARCHAR(1024) NOT NULL DEFAULT 'authorization_code,refresh_token,implicit,client_credentials',
  resource_ids VARCHAR(1024),
  PRIMARY KEY (client_id),
  FOREIGN KEY (app_id) REFERENCES applications(app_id)
);

CREATE TABLE roles (
  role_id BIGINT NOT NULL AUTO_INCREMENT,
  role_name VARCHAR(64) NOT NULL,
  role_description VARCHAR(1024), 
  PRIMARY KEY (role_id),
  UNIQUE KEY (role_name) 
);

CREATE TABLE ldap_memberships (
  ldap_name VARCHAR(128) NOT NULL,
  role_id BIGINT NOT NULL,
  PRIMARY KEY (ldap_name, role_id),
  FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE users (
  username VARCHAR(64) NOT NULL,
  fullname VARCHAR(64) NOT NULL,
  email VARCHAR(128), 
  enabled tinyint NOT NULL DEFAULT 1,
  password_hash VARCHAR(128),
  password_enabled tinyint NOT NULL DEFAULT 0,
  last_login TIMESTAMP,
  PRIMARY KEY (username)
);

CREATE TABLE user_memberships (
  username VARCHAR(64) NOT NULL, 
  role_id BIGINT NOT NULL, 
  start_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expire_date DATETIME,
  PRIMARY KEY (username, role_id),
  FOREIGN KEY (username) REFERENCES users(username),
  FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

CREATE TABLE verbs (
  verb_name VARCHAR(16) NOT NULL PRIMARY KEY
);

INSERT INTO verbs (verb_name) values ('ACCESS');
INSERT INTO verbs (verb_name) values ('CREATE');
INSERT INTO verbs (verb_name) values ('READ');
INSERT INTO verbs (verb_name) values ('UPDATE');
INSERT INTO verbs (verb_name) values ('DELETE');
INSERT INTO verbs (verb_name) values ('LIST');
INSERT INTO verbs (verb_name) values ('ENABLE');
INSERT INTO verbs (verb_name) values ('METAREAD');
INSERT INTO verbs (verb_name) values ('METAWRITE');
INSERT INTO verbs (verb_name) values ('EXECUTE');
INSERT INTO verbs (verb_name) values ('REQUEST');
INSERT INTO verbs (verb_name) values ('APPROVE');
INSERT INTO verbs (verb_name) values ('GRANT');


CREATE TABLE actions (
  action_id BIGINT NOT NULL AUTO_INCREMENT,
  app_id BIGINT NOT NULL,
  resource_type VARCHAR(24) NOT NULL,
  verb VARCHAR(16) NOT NULL,
  action_description VARCHAR(1024) NOT NULL,
  PRIMARY KEY (action_id),
  FOREIGN KEY (app_id) references applications(app_id),
  FOREIGN KEY (verb) references verbs(verb_name)
);

CREATE TABLE application_permissions (
  role_id BIGINT NOT NULL,
  action_id BIGINT NOT NULL, 
  PRIMARY KEY (role_id, action_id)
);

CREATE TABLE tenants (
  tenant_id BIGINT NOT NULL AUTO_INCREMENT,
  tenant_name VARCHAR(64) NOT NULL,
  tenant_description VARCHAR(1024),
  PRIMARY KEY (tenant_id),
  UNIQUE KEY (tenant_name)
);

CREATE TABLE tenant_permissions (
  role_id BIGINT NOT NULL,
  action_id BIGINT NOT NULL, 
  tenant_id BIGINT NOT NULL, 
  PRIMARY KEY (role_id, action_id, tenant_id)
);


DELIMITER $$

DROP PROCEDURE IF EXISTS loadPermissions
$$
CREATE PROCEDURE loadPermissions(IN client_id VARCHAR(64), IN group_csv VARCHAR(1024))
BEGIN
  SELECT DISTINCT permission FROM (
    SELECT CONCAT(ac.resource_type, '::', ac.verb) as permission
    from clients c, actions ac, application_permissions p, roles r
    where c.client_id = client_id and c.app_id = ac.app_id and ac.action_id = p.action_id and p.role_id = r.role_id 
    and c.client_id = client_id
    and FIND_IN_SET (r.role_name, group_csv) 
    UNION ALL 
    SELECT CONCAT(t.tenant_name, '::', ac.resource_type, '::', ac.verb) as permission
    from clients c, actions ac, tenants t, tenant_permissions p, roles r
    where c.client_id = client_id and c.app_id = ac.app_id and ac.action_id = p.action_id and t.tenant_id = p.tenant_id and p.role_id = r.role_id
    and c.client_id = client_id
    and FIND_IN_SET (r.role_name, group_csv) 
  ) a ORDER BY permission asc;
END
$$

DROP PROCEDURE IF EXISTS getTenants
$$
CREATE PROCEDURE getTenants(IN client_id VARCHAR(64), IN group_csv VARCHAR(1024))
BEGIN
  SELECT t.tenant_name
  from clients c, tenants t, tenant_permissions p, roles r
  where c.app_id = p.app_id and t.tenant_id = p.tenant_id and p.role_id = r.role_id
  and a.app_name = app_name
  and FIND_IN_SET (r.role_name, group_csv)
  ORDER BY t.tenant_name asc;
END
$$

DROP PROCEDURE IF EXISTS createApplicationPermission
$$
CREATE PROCEDURE createApplicationPermission(IN app_name VARCHAR(64), IN role_name VARCHAR(64), IN resource_type VARCHAR(24), IN verb VARCHAR(16), IN action_description VARCHAR(1024))
BEGIN
  DECLARE app_id BIGINT;
  DECLARE action_id BIGINT;
  DECLARE role_id BIGINT;

  INSERT IGNORE INTO roles (role_name) values (role_name);

  SELECT a.app_id from applications a where a.app_name = app_name limit 1 into app_id;
  SELECT r.role_id from roles r where r.role_name = role_name limit 1 into role_id;

  INSERT INTO actions (app_id, resource_type, verb, action_description) values (app_id, resource_type, verb, action_description);
  SET action_id = LAST_INSERT_ID();
  INSERT INTO application_permissions (action_id, role_id) values (action_id, role_id);
END
$$

DROP PROCEDURE IF EXISTS createTenantPermission
$$
CREATE PROCEDURE createTenantPermission(IN app_name VARCHAR(64), 
  IN role_name VARCHAR(64), IN tenant_name VARCHAR(64), 
  IN resource_type VARCHAR(24), IN verb VARCHAR(16), IN action_description VARCHAR(1024))
BEGIN
  DECLARE app_id BIGINT;
  DECLARE action_id BIGINT;
  DECLARE role_id BIGINT;
  DECLARE tenant_id BIGINT;

  INSERT IGNORE INTO roles (role_name) values (role_name);
  INSERT IGNORE INTO tenants (tenant_name) values (tenant_name);

  SELECT a.app_id from applications a where a.app_name = app_name limit 1 into app_id;
  SELECT r.role_id from roles r where r.role_name = role_name limit 1 into role_id;
  SELECT t.tenant_id from tenants t where t.tenant_name = tenant_name limit 1 into tenant_id;

  INSERT INTO actions (app_id, resource_type, verb) values (app_id, resource_type, verb);
  SET action_id = LAST_INSERT_ID();
  INSERT INTO tenant_permissions (action_id, role_id, tenant_id) values (action_id, role_id, tenant_id);
END
$$

DROP PROCEDURE IF EXISTS createUser
$$
CREATE PROCEDURE createUser(IN username VARCHAR(64), 
  IN fullname VARCHAR(64), 
  IN email VARCHAR(128) )
BEGIN
  INSERT INTO users (username, fullname, email) values (username, fullname, email);
END
$$

DROP PROCEDURE IF EXISTS setUserPassword
$$
CREATE PROCEDURE setUserPassword(IN username VARCHAR(64), 
  IN password_hash VARCHAR(128))
BEGIN
  UPDATE users u
  SET u.password_hash = password_hash, u.password_enabled=1
  WHERE u.username = username;
END
$$

DROP PROCEDURE IF EXISTS loadUser
$$
CREATE PROCEDURE loadUser(IN username VARCHAR(64) )
BEGIN
  SELECT u.username, u.fullname, u.email, u.enabled, u.password_hash, u.password_enabled
  FROM users u
  WHERE u.username = username 
  AND u.password_hash IS NOT NULL 
  AND u.password_enabled = 1;
END
$$

DROP PROCEDURE IF EXISTS trackLogin
$$
CREATE PROCEDURE trackLogin(IN username VARCHAR(64), IN fullname VARCHAR(64), IN email VARCHAR(128) )
BEGIN
  INSERT INTO users (username, fullname, email, last_login)
  VALUES ( username, fullname, email, current_timestamp() )
  ON DUPLICATE KEY 
  UPDATE fullname=VALUES(fullname), email=VALUES(email), last_login=VALUES(last_login);
END
$$

DROP PROCEDURE IF EXISTS createApplication
$$
CREATE PROCEDURE createApplication(IN app_name VARCHAR(64), IN app_label VARCHAR(64) )
BEGIN
  INSERT INTO applications (app_name, app_label) values (app_name, app_label);
END
$$

DROP PROCEDURE IF EXISTS createRole
$$
CREATE PROCEDURE createRole(IN role_name VARCHAR(64), IN role_description VARCHAR(1024) )
BEGIN
  INSERT INTO roles (role_name, role_description) values (role_name, role_description);
END
$$

DROP PROCEDURE IF EXISTS createLdapRole
$$
CREATE PROCEDURE createLdapRole(IN ldap_name VARCHAR(64) )
BEGIN
  CALL createLdapMembership(ldap_name, null);
END
$$

DROP PROCEDURE IF EXISTS createLdapMembership
$$
CREATE PROCEDURE createLdapMembership(IN ldap_name VARCHAR(64), IN role_name VARCHAR(64) )
BEGIN

  DECLARE role_id BIGINT;
  SET role_name = IFNULL(role_name, ldap_name);

  INSERT IGNORE INTO roles (role_name, role_description) values (role_name, concat('Mapping from ldap role ', ldap_name));
  SELECT r.role_id from roles r where r.role_name = role_name limit 1 into role_id;
  INSERT IGNORE INTO ldap_memberships (ldap_name, role_id) values (ldap_name, role_id);
END
$$

DROP PROCEDURE IF EXISTS loadRoles
$$
CREATE PROCEDURE loadRoles(IN username VARCHAR(64), IN ldap_group_csv VARCHAR(1024) )
BEGIN
  SELECT DISTINCT role_name FROM (
    SELECT r.role_name
    FROM roles r, user_memberships m
    WHERE m.username = username 
    AND m.role_id = r.role_id
    UNION ALL
    SELECT r.role_name
    FROM roles r, ldap_memberships m 
    WHERE r.role_id = m.role_id 
    AND FIND_IN_SET (m.ldap_name, ldap_group_csv) 
  ) a ORDER BY role_name asc;
END
$$

DROP PROCEDURE IF EXISTS createUserMembership
$$
CREATE PROCEDURE createUserMembership(IN username VARCHAR(64), IN role_name VARCHAR(64))
BEGIN
  DECLARE app_id BIGINT;
  DECLARE action_id BIGINT;
  DECLARE role_id BIGINT;
  DECLARE tenant_id BIGINT;

  INSERT IGNORE INTO roles (role_name) values (role_name);

  SELECT r.role_id from roles r where r.role_name = role_name limit 1 into role_id;
  INSERT INTO user_memberships (username, role_id) values (username, role_id);
END
$$

DROP PROCEDURE IF EXISTS loadClient
$$
CREATE PROCEDURE loadClient(IN client_id VARCHAR(64))
BEGIN
  SELECT c.client_id, c.client_secret, c.redirect_urls, c.authorities, 
  c.scopes, c.auto_approve_scopes, c.grant_types, c.resource_ids,
  a.app_name, a.app_label
  FROM clients c, applications a
  WHERE c.client_id = client_id
  AND c.app_id = a.app_id
  AND c.enabled = 1;
END
$$

DROP PROCEDURE IF EXISTS createClient
$$
CREATE PROCEDURE createClient(IN app_name VARCHAR(64), IN client_id VARCHAR(64),
  IN client_secret VARCHAR(128), IN redirect_urls VARCHAR(1024))
BEGIN
  DECLARE app_id BIGINT;

  SELECT a.app_id from applications a where a.app_name = app_name limit 1 into app_id;
  INSERT INTO clients (app_id, client_id, client_secret, redirect_urls) 
  VALUES (app_id, client_id, client_secret, redirect_urls);
END
$$

DROP PROCEDURE IF EXISTS createTrustedClient
$$
CREATE PROCEDURE createTrustedClient(IN app_name VARCHAR(64), IN client_id VARCHAR(64),
  IN client_secret VARCHAR(128), IN redirect_urls VARCHAR(1024))
BEGIN
  DECLARE app_id BIGINT;

  SELECT a.app_id from applications a where a.app_name = app_name limit 1 into app_id;
  INSERT INTO clients (app_id, client_id, client_secret, redirect_urls, grant_types, authorities) 
  VALUES (app_id, client_id, client_secret, redirect_urls, 
    'authorization_code,refresh_token,implicit,client_credentials,password',
    'ROLE_CLIENT,ROLE_TRUSTED_CLIENT');
END
$$

DELIMITER ;

CALL createRole('VA_USER', 'Standard users of Volume Analytics');
CALL createRole('VA_OPERATOR', 'Operators of the Volume Analytics platform');
CALL createRole('VA_ADMIN', 'Super users of the Volume Analytics platform');

CALL createApplication('VA', 'Volume Analytics');
CALL createApplicationPermission('VA', 'VA_USER', 'APPLICATION', 'ACCESS', 'Permitted to access the application');
CALL createApplicationPermission('VA', 'VA_ADMIN', 'MONITOR', 'ACCESS', 'Permitted to access the users section of the application');
CALL createApplicationPermission('VA', 'VA_ADMIN', 'USERS', 'ACCESS', 'Permitted to access the users section of the application');

GRANT ALL on volume_users.* to 'volume_manager'@'%';
GRANT EXECUTE on procedure volume_users.loadUser to 'volume_gateway'@'%';
GRANT EXECUTE on procedure volume_users.loadRoles to 'volume_gateway'@'%';
GRANT EXECUTE on procedure volume_users.loadClient to 'volume_gateway'@'%';
GRANT EXECUTE on procedure volume_users.loadPermissions to 'volume_gateway'@'%';
GRANT EXECUTE on procedure volume_users.trackLogin to 'volume_gateway'@'%';
