package routes

import "github.com/gofiber/fiber"

// Ping : testing endpoint.
func Ping(c *fiber.Ctx) error {
	return c.SendString("Pong!")
}