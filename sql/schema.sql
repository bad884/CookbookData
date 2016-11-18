CREATE TABLE Users (
	UserID INT PRIMARY KEY,
	Password VARCHAR(32) NOT NULL
		CHECK (Password REGEXP '^[[:alnum:]]{6,}$'),
	FirstName VARCHAR(32)
		CHECK (FirstName REGEXP '^[[:alpha:][.apostrophe.][.hyphen.]]+$'), 
	LastName VARCHAR(32)
		CHECK (LastName REGEXP '^[[:alpha:][.apostrophe.][.hyphen.]]+$')
);

CREATE TABLE SavedSearches (
	SearchID INT,
	SearchName VARCHAR(64) NOT NULL CHECK (SearchName REGEXP '^[[:alnum:][.space.]]+$'), 
	UserID INT NOT NULL,
	FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (SearchID, UserID)
);

CREATE TABLE Recipes (
	RecipeID INT PRIMARY KEY,
	Title VARCHAR(64) NOT NULL,
	Description VARCHAR(2048),
	Instructions VARCHAR(2048),
	IsPrivate TINYINT,
	ParentRecipeID INT,
	FOREIGN KEY (ParentRecipeID) REFERENCES Recipes(RecipeID) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Tags (
	TagName VARCHAR(64) PRIMARY KEY
);

CREATE TABLE FoodGroups (
	FoodGroupID INT PRIMARY KEY,
	Name VARCHAR(64) NOT NULL
);

CREATE TABLE Ingredients (
	IngredientID INT PRIMARY KEY,
	FoodGroupID INT NOT NULL,
	FOREIGN KEY (FoodGroupID) REFERENCES FoodGroup(FoodGroupID),
	Name VARCHAR(256) NOT NULL
);

CREATE TABLE Nutrients (
	NutrientID INT PRIMARY KEY,
	Unit VARCHAR(64),
	Name VARCHAR(128) NOT NULL
);

CREATE TABLE GramMappings (
	IngredientID INT NOT NULL,
	SequenceNumber int NOT NULL,
	AmountCommonMeasure DOUBLE NOT NULL CHECK (AmountCommonMeasure > 0),
	CommonMeasure VARCHAR(128) NOT NULL,
	AmountGrams DOUBLE NOT NULL CHECK (AmountGrams > 0),
	PRIMARY KEY (IngredientID, SequenceNumber)
);

CREATE TABLE SearchTags (
	SearchID INT NOT NULL,
	TagName VARCHAR(64) NOT NULL,
	FOREIGN KEY (SearchID) REFERENCES SavedSearches(SearchID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (TagName) REFERENCES Tags(TagName) ON DELETE CASCADE ON UPDATE CASCADE,
	Include TINYINT NOT NULL,
	PRIMARY KEY (SearchID, TagName)
);

CREATE TABLE SearchFoodGroups (
	SearchID INT NOT NULL,
	FoodGroupID INT NOT NULL,
	FOREIGN KEY (SearchID) REFERENCES SavedSearches(SearchID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (FoodGroupID) REFERENCES FoodGroup(FoodGroupID) ON DELETE CASCADE ON UPDATE CASCADE,
	Include TINYINT NOT NULL,
	PRIMARY KEY (SearchID, FoodGroupID)
);

CREATE TABLE UserFavorites (
	UserID INT NOT NULL,
	RecipeID INT NOT NULL,
	FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (UserID, RecipeID)
);

CREATE TABLE UserSubmittedRecipes (
	UserID INT NOT NULL,
	RecipeID INT NOT NULL,
	FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (UserID, RecipeID)
);

CREATE TABLE RecipeIngredients (
	RecipeID INT NOT NULL,
	IngredientID INT NOT NULL,
	FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (IngredientID) REFERENCES Ingredients(IngredientID) ON DELETE CASCADE ON UPDATE CASCADE,
	Amount DOUBLE NOT NULL CHECK (Amount > 0),
	Unit VARCHAR(128) NOT NULL,
	CHECK (
		(IngredientID, Unit) IN (
		SELECT DISTINCT IngredientID, CommonMeasure
		FROM GramMappings
		)
		OR Unit="g"
	),
	PRIMARY KEY (RecipeID, IngredientID)
);

CREATE TABLE RecipeTags (
	RecipeID INT NOT NULL,
	TagName VARCHAR(64) NOT NULL,
	FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (TagName) REFERENCES Tags(TagName) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (RecipeID, TagName)
);

CREATE TABLE IngredientNutrients (
	IngredientID INT NOT NULL,
	NutrientID INT NOT NULL,
	FOREIGN KEY (IngredientID) REFERENCES Ingredients(IngredientID) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (NutrientID) REFERENCES Nutrients(NutrientID) ON DELETE CASCADE ON UPDATE CASCADE,
	Amount DOUBLE NOT NULL CHECK (Amount >= 0),
	PRIMARY KEY (IngredientID, NutrientID)
);

CREATE TABLE LoggedInUsers (
	UserID INT NOT NULL,
	FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (UserID)
);
