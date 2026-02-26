const express = require('express')
const router = express.Router();
const todoController = require("../controllers/todo.controller")

router.post("/create",todoController.createTask)

router.get("/get",todoController.getTask)

router.put("/update/:id",todoController.completionTask);

router.put("/edit/:id",todoController.editTask)

router.delete("/delete/:id",todoController.deleteTask)

module.exports = router