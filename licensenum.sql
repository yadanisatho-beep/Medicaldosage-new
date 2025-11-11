USE medicaldosagedb;
DROP TABLE IF EXISTS licenses; 


CREATE TABLE licenses (
    licenseNumber VARCHAR(20) PRIMARY KEY, 
    status VARCHAR(50) NOT NULL,            
    issueDate DATE                          
);

INSERT INTO licenses (licenseNumber, status, issueDate) VALUES
('LIC-0001-ABC', 'active', '2020-01-15'),
('LIC-0002-DEF', 'active', '2020-02-20'),
('LIC-0003-GHI', 'active', '2020-03-10'),
('LIC-0004-JKL', 'active', '2020-04-05'),
('LIC-0005-MNO', 'active', '2020-05-12'),
('LIC-0006-PQR', 'active', '2020-06-18'),
('LIC-0007-STU', 'active', '2020-07-22'),
('LIC-0008-VWX', 'active', '2020-08-30'),
('LIC-0009-YZA', 'active', '2020-09-14'),
('LIC-0010-BCD', 'active', '2020-10-25'),
('LIC-0011-EFG', 'active', '2020-11-29'),
('LIC-0012-HIJ', 'active', '2020-12-05'),
('LIC-0013-KLM', 'active', '2021-01-18'),
('LIC-0014-NOP', 'active', '2021-02-22'),
('LIC-0015-QRS', 'active', '2021-03-01'),
('LIC-0016-TUV', 'active', '2021-04-10'),
('LIC-0017-WXY', 'active', '2021-05-15'),
('LIC-0018-ZAB', 'active', '2021-06-20'),
('LIC-0019-CDE', 'active', '2021-07-25'),
('LIC-0020-FGH', 'active', '2021-08-30'),
('LIC-0021-IJK', 'active', '2021-09-04');