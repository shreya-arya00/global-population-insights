-- Create schema for storing Continents, Countries, and People
CREATE TABLE Continents (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE Countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    population INT,
    area DECIMAL(10,2),
    continent_id INT REFERENCES Continents(id)
);

CREATE TABLE People (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE CountriesPeople (
    country_id INT REFERENCES Countries(id),
    person_id INT REFERENCES People(id),
    PRIMARY KEY (country_id, person_id)
);

-- Populate Continents table
INSERT INTO Continents (name) VALUES
('Asia'),
('Africa'),
('Europe'),
('North America'),
('South America'),
('Australia');

-- Populate Countries table
INSERT INTO Countries (name, population, area, continent_id) VALUES
('China', 1400000000, 9706961, 1),
('India', 1370000000, 3287263, 1),
('United States', 330000000, 9372610, 4),
('Brazil', 212000000, 8515770, 5),
('Russia', 145000000, 17098242, 3),
('Canada', 38000000, 9976140, 4),
('Australia', 25000000, 7692024, 6),
('Nigeria', 206000000, 923768, 2);

-- Populate People table
INSERT INTO People (name) VALUES
('John Smith'),
('Emma Johnson'),
('Michael Brown'),
('Linda Wilson'),
('Robert Martinez');

-- Populate CountriesPeople table (random assignment of people to countries)
INSERT INTO CountriesPeople (country_id, person_id)
SELECT 
    country_id,
    (SELECT id FROM People ORDER BY random() LIMIT 1) AS person_id
FROM 
    Countries
CROSS JOIN 
    generate_series(1, 5); -- Adjust the number 5 to the number of citizens you want to randomly assign to each country

-- Write SQL queries to find data about countries
-- Country with the biggest population (id and name of the country)
SELECT id, name
FROM Countries
ORDER BY population DESC
LIMIT 1;

-- Top 10 countries with the lowest population density (names of the countries)
SELECT name
FROM Countries
ORDER BY population / area
LIMIT 10;

-- Countries with population density higher than average across all countries
SELECT *
FROM Countries
WHERE population / area > (SELECT AVG(population / area) FROM Countries);

-- Country with the longest name (if several countries have name of the same length, show all of them)
SELECT id, name
FROM Countries
WHERE LENGTH(name) = (SELECT MAX(LENGTH(name)) FROM Countries);

-- All countries with name containing letter “F”, sorted in alphabetical order
SELECT *
FROM Countries
WHERE name LIKE '%F%'
ORDER BY name;

-- Country which has a population, closest to the average population of all countries
SELECT id, name
FROM Countries
ORDER BY ABS(population - (SELECT AVG(population) FROM Countries))
LIMIT 1;

-- Write SQL queries to find data about countries and continents
-- Count of countries for each continent
SELECT c.name AS continent, COUNT(co.id) AS country_count
FROM Continents c
LEFT JOIN Countries co ON c.id = co.continent_id
GROUP BY c.name;

-- Total area for each continent (print continent name and total area), sorted by area from biggest to smallest
SELECT c.name AS continent, SUM(co.area) AS total_area
FROM Continents c
LEFT JOIN Countries co ON c.id = co.continent_id
GROUP BY c.name
ORDER BY total_area DESC;

-- Average population density per continent
SELECT c.name AS continent, AVG(co.population / co.area) AS avg_population_density
FROM Continents c
LEFT JOIN Countries co ON c.id = co.continent_id
GROUP BY c.name;

-- For each continent, find a country with the smallest area (print continent name, country name and area)
SELECT c.name AS continent, co.name AS country, co.area
FROM Continents c
LEFT JOIN Countries co ON c.id = co.continent_id
WHERE (co.area, c.id) IN (
    SELECT MIN(co.area), c.id
    FROM Countries co
    GROUP BY c.id
);

-- Find all continents, which have average country population less than 20 million
SELECT c.name AS continent
FROM Continents c
LEFT JOIN Countries co ON c.id = co.continent_id
GROUP BY c.name
HAVING AVG(co.population) < 20000000;

-- Write SQL queries to find data about people
-- Person with the biggest number of citizenships
SELECT p.id, p.name
FROM People p
JOIN CountriesPeople cp ON p.id = cp.person_id
GROUP BY p.id, p.name
ORDER BY COUNT(cp.country_id) DESC
LIMIT 1;

-- All people who have no citizenship
SELECT *
FROM People
WHERE id NOT IN (SELECT person_id FROM CountriesPeople);

-- Country with the least people in People table
SELECT c.name
FROM Countries c
LEFT JOIN CountriesPeople cp ON c.id = cp.country_id
GROUP BY c.id
ORDER BY COUNT(cp.person_id)
LIMIT 1;

-- Continent with the most people in People table
SELECT co.name AS continent
FROM Continents co
JOIN Countries c ON co.id = c.continent_id
JOIN CountriesPeople cp ON c.id = cp.country_id
GROUP BY co.id
ORDER BY COUNT(cp.person_id) DESC
LIMIT 1;

-- Find pairs of people with the same name - print 2 ids and the name
SELECT p1.id AS person1_id, p2.id AS person2_id, p1.name
FROM People p1, People p2
WHERE p1.id < p2.id AND p1.name = p2.name;
