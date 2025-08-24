package controller

import (
	// "fmt"
	"intern_template_v1/middleware"
	"intern_template_v1/model"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

// SampleController is an example endpoint which returns a
// simple string message.
func SampleController(c *fiber.Ctx) error {
	return c.SendString("Hello, Golang World!")
}

// CreateUser adds a new Account to the database
func CreateUser(c *fiber.Ctx) error {
	NewUser := new(model.Account)
	if err := c.BodyParser(NewUser); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "Invalid request body"})
	}
	if err := middleware.DBConn.Table("accounts").Create(&NewUser).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"error": "Failed to create NewUser"})
	}
	return c.JSON(NewUser)
}

// CreateApprovalStatus creates an approval status record for a specific user
func CreateApprovalStatus(c *fiber.Ctx) error {
	var input model.ApprovalStatus

	// Bind JSON to struct
	if err := c.BodyParser(&input); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Check if account exists
	var account model.Account
	if err := middleware.DBConn.First(&account, "id = ?", input.AccountID).Error; err != nil {
		return c.Status(http.StatusNotFound).JSON(fiber.Map{
			"error": "Account not found",
		})
	}

	// Prevent duplicate approval status
	var existing model.ApprovalStatus
	if err := middleware.DBConn.Where("account_id = ?", input.AccountID).First(&existing).Error; err == nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Approval status already exists for this user",
		})
	}

	// Default status
	if input.Status == "" {
		input.Status = "Pending"
	}

	// Create record
	if err := middleware.DBConn.Create(&input).Error; err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to create approval status",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Approval status created",
		"data":    input,
	})
}

// ApproveUser updates approval status to "Approved" if all 4 requirements are true
func ApproveUser(c *fiber.Ctx) error {
	accountIDParam := c.Params("id")

	// Parse UUID
	accountID, err := uuid.Parse(accountIDParam)
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid account ID format",
		})
	}

	// Find the approval status by account ID
	var status model.ApprovalStatus
	if err := middleware.DBConn.Where("account_id = ?", accountID).First(&status).Error; err != nil {
		return c.Status(http.StatusNotFound).JSON(fiber.Map{
			"error": "Approval status not found for this user",
		})
	}

	// Check all 4 requirements
	if status.Requirement1 && status.Requirement2 && status.Requirement3 && status.Requirement4 {
		status.Status = "Approved"
		status.IsApproved = true

		// Save changes
		if err := middleware.DBConn.Save(&status).Error; err != nil {
			return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to approve user",
			})
		}

		return c.JSON(fiber.Map{
			"message": "User approved successfully",
			"status":  status,
		})
	}

	// If not all requirements are met
	return c.Status(http.StatusBadRequest).JSON(fiber.Map{
		"error": "User cannot be approved. Not all requirements are met.",
		"status": fiber.Map{
			"requirement_1": status.Requirement1,
			"requirement_2": status.Requirement2,
			"requirement_3": status.Requirement3,
			"requirement_4": status.Requirement4,
		},
	})
}
