package routes

import (
	"intern_template_v1/controller"

	"github.com/gofiber/fiber/v2"
)

func AppRoutes(app *fiber.App) {
	// SAMPLE ENDPOINT
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello Golang World!")
	})

	// CREATE YOUR ENDPOINTS HERE
	api := app.Group("/api")

	// api.Get("/users", controller.GetUsers)
	api.Post("/users", controller.CreateUser)
	api.Post("/approval", controller.CreateApprovalStatus)
	api.Put("/users/:id/approve", controller.ApproveUser)
	// api.Put("/users/:id", controller.UpdateUser)
	// api.Delete("/users/:id", controller.DeleteUser)
	// --------------------------

	// Register endpoint (old code)
	// app.Post("/api/register", func(c *fiber.Ctx) error {
	// 	var data struct {
	// 		ApplicationType string `json:"application_type"`
	// 		DateApplied     string `json:"date_applied"`
	// 		LastName        string `json:"last_name"`
	// 		FirstName       string `json:"first_name"`
	// 		Birthday        string `json:"birthday"`
	// 		Mobile          string `json:"mobile"`
	// 		Barangay        string `json:"barangay"`
	// 	}

	// 	if err := c.BodyParser(&data); err != nil {
	// 		return c.Status(400).JSON(fiber.Map{"error": "Invalid request"})
	// 	}

	// 	// ✅ Print to console to verify data is received
	// 	fmt.Printf("📥 Received form data: %+v\n", data)

	// 	// TODO: Insert into PostgreSQL
	// 	return c.JSON(fiber.Map{"message": "Data received successfully!"})
	// })

	// Register endpoint using controller
	// api.Post("/register", controller.RegisterUser) // now handled by controller
	// --------------------------
}
