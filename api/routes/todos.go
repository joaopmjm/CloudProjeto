package routes

import (
	"github.com/gofiber/fiber/v2"
	"github.com/joaopmjm/CloudProjeto/blob/main/api/db/db"
	"github.com/joaopmjm/CloudProjeto/blob/main/api/models/TODOS"
	"gorm.io/gorm"
)

func GetTodos(c *fiber.Ctx) error {
	var db *gorm.DB = database.DBConn
	var todos []models.Todo

	db.Find(&todos)

	return c.Status(200).JSON(fiber.Map{
		"todos": todos,
	})
}

func GetTodo(c *fiber.Ctx) error {
	var db *gorm.DB = database.DBConn
	var id string = c.Params("id")
	var todo models.Todo

	result := db.First(&todo, id)
	if result.RowsAffected == 0 {
		return c.Status(404).JSON(fiber.Map{
			"error": "Could not find todo with given Id",
		})
	}

	return c.JSON(todo)
}

func NewTodo(c *fiber.Ctx) error {
	var db *gorm.DB = database.DBConn
	var newTodo *models.NewTodo = new(models.NewTodo)
	var err error

	err = c.BodyParser(newTodo)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"error": "Could not create todo",
		})
	}

	if newTodo.Title == "" {
		return c.Status(400).JSON(fiber.Map{
			"error": "Missing todo title",
		})
	}

	db.Table("todos").Create(&newTodo)

	return c.JSON(fiber.Map{
		"id": newTodo.Id,
	})
}

func DeleteTodo(c *fiber.Ctx) error {
	var db *gorm.DB = database.DBConn
	var id string = c.Params("id")
	var todo models.Todo

	result := db.Delete(&todo, id)
	if result.RowsAffected == 0 {
		return c.Status(404).JSON(fiber.Map{
			"error": "Could not find todo with given Id",
		})
	}

	return c.Status(200).JSON(fiber.Map{
		"message": "Todo deleted",
	})
}

func UpdateTodo(c *fiber.Ctx) error {
	var db *gorm.DB = database.DBConn

	var todo *models.Todo = new(models.Todo)
	var newTodo *models.NewTodo = new(models.NewTodo)
	var err error

	err = c.BodyParser(newTodo)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"error": "Could not update todo",
		})
	}

	result := db.Model(&todo).Where("id = ?", newTodo.Id).Updates(models.Todo{Title: newTodo.Title, Description: newTodo.Description})
	if result.RowsAffected == 0 {
		return c.Status(404).JSON(fiber.Map{
			"error": "Could not find todo with given ID or no fields were updated",
		})
	}

	return c.Status(200).JSON(fiber.Map{
		"message": "Todo updated",
	})
}