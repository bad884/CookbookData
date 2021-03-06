@GIVEN <- cookbook_savedsearch.id

SELECT DISTINCT cookbook_recipe.*
FROM cookbook_recipe
INNER JOIN cookbook_recipetag ON cookbook_recipetag.recipe_id = cookbook_recipe.id
INNER JOIN cookbook_recipeingredient ON cookbook_recipeingredient.recipe_id = cookbook_recipe.id
INNER JOIN cookbook_ingredient ON cookbook_ingredient.id = cookbook_recipeingredient.ingredient_id
INNER JOIN cookbook_foodgroup ON cookbook_foodgroup.id = cookbook_ingredient.food_group_id
WHERE
	CASE /*Search on Recipe Names*/
		WHEN (SELECT CASE WHEN recipe_search_term is not null THEN True ELSE False END FROM cookbook_savedsearch WHERE id = @GIVEN)
			THEN cookbook_recipe.title like '%' || (SELECT recipe_search_term FROM cookbook_savedsearch WHERE id = @GIVEN) || '%'
		ELSE True
	END
	AND
	CASE /*Search on Ingredient Names*/
		WHEN (SELECT CASE WHEN ingredient_search_term is not null THEN True ELSE False END FROM cookbook_savedsearch WHERE id = @GIVEN)
			THEN cookbook_ingredient.name like '%' || (SELECT ingredient_search_term FROM cookbook_savedsearch WHERE id = @GIVEN) || '%'
		ELSE True
	END
	AND
	CASE /*Search on FoodGroups (include)*/
		WHEN (SELECT CASE WHEN count(*) > 0 THEN True ELSE False END FROM cookbook_searchfoodgroup WHERE search_id = @GIVEN AND include = 't')
			THEN cookbook_ingredient.food_group_id in (SELECT food_group_id FROM cookbook_searchfoodgroup WHERE search_id = @GIVEN AND include = 't')
		ELSE True
	END
	AND
	CASE /*Search on FoodGroups (exclude)*/
		WHEN (SELECT CASE WHEN count(*) > 0 THEN True ELSE False END FROM cookbook_searchfoodgroup WHERE search_id = @GIVEN AND include = 'f')
			THEN cookbook_ingredient.food_group_id not in (SELECT food_group_id FROM cookbook_searchfoodgroup WHERE search_id = @GIVEN AND include = 'f')
		ELSE True
	END
	AND
	CASE /*Search on Tags (include)*/
		WHEN (SELECT CASE WHEN count(*) > 0 THEN True ELSE False END FROM cookbook_searchtag WHERE search_id = @GIVEN AND include = 't')
			THEN cookbook_recipetag.tag_id in (SELECT tag_id FROM cookbook_searchtag WHERE search_id = @GIVEN and include = 't')
		ELSE True
	END
	AND
	CASE /*Search on Tags (exclude)*/
		WHEN (SELECT CASE WHEN count(*) > 0 THEN True ELSE False END FROM cookbook_searchtag WHERE search_id = @GIVEN AND include = 'f')
			THEN cookbook_recipetag.tag_id not in (SELECT tag_id FROM cookbook_searchtag WHERE search_id = @GIVEN and include = 'f')
		ELSE True
	END
;