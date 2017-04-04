use volume_users;

CALL volume_users.createTrustedClient('VA', 'manager', 'mopassword', null); 
CALL volume_users.createTrustedClient('VA', 'gateway', 'gopassword', null);


CALL createUser('Red Ranger-X ABCD03', 'Red Ranger-X ABCD03', 'red@volumeintegration.com');
CALL createUserMembership('Red Ranger-X ABCD03', 'VA_USER');
CALL createUserMembership('Red Ranger-X ABCD03', 'VA_ADMIN');

CALL createUser('Black Ranger-X ABCD04', 'Black Ranger-X ABCD04', 'black@volumeintegration.com');
CALL createUserMembership('Black Ranger-X ABCD04', 'VA_USER');
CALL createUserMembership('Black Ranger-X ABCD04', 'VA_ADMIN');

CALL createUser('Pink Ranger-X ABCD01', 'Pink Ranger-X ABCD01', 'pink@volumeintegration.com');
CALL createUserMembership('Pink Ranger-X ABCD01', 'VA_USER');

CALL createUser('Blue Ranger-X ABCD03', 'Blue Ranger-X ABCD03', 'blue@volumeintegration.com');
CALL createUserMembership('Blue Ranger-X ABCD03', 'VA_USER');

CALL createUser('Yellow Ranger-X ABCD02', 'Yellow Ranger-X ABCD02', 'yellow@volumeintegration.com');

-- create a password user
CALL createUser('backdoor', 'Evil Backdoor', 'evil@volumeintegration.com');
CALL setUserPassword('backdoor', '$2a$06$GZOUqJlGIxbeBJLn0ctPruZMhz0kz247bhqzsxwhGfFPt2LoaSYzC'); -- password123
CALL createUserMembership('backdoor', 'VA_USER');
CALL createUserMembership('backdoor', 'VA_ADMIN');

CALL createUser('admin', 'Administrator', 'admin@volumeintegration.com');
CALL setUserPassword('admin', '$2a$06$Xdw7nqI7svjz3gH3Lble3.70qCijwaDVx9wJvMu6DJZK0YIde0gLK'); -- password
CALL createUserMembership('admin', 'VA_USER');
CALL createUserMembership('admin', 'VA_ADMIN');

-- cre
CALL createApplication('CRE', 'cre duh');
CALL createRole('CRE_USER', 'cre user');
CALL createRole('CRE_ADMIN', 'cre admin');
CALL createClient('CRE', 'cre', 'crepassword', null);
CALL createUserMembership('Black Ranger-X ABCD04', 'CRE_USER');
CALL createUserMembership('Black Ranger-X ABCD04', 'CRE_ADMIN');
CALL createUserMembership('Pink Ranger-X ABCD01', 'CRE_USER');
