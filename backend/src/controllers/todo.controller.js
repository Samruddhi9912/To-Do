const todomodel = require("../models/todo.model");


async function createTask(req,res){
    try{
        const newTodo = await todomodel.create({
            title: req.body.title,
            targetDate: req.body.targetDate
        });
        res.status(201).json(newTodo);
    }
    catch(error){
        console.error();
        res.status(500).json({
            message: "Error in creating task",
        })
    }
}

async function getTask(req,res){
    try{
        const todos = await todomodel.find();
        res.status(200).json({
            message: "Task fetched Successfully",
            todos
        });
    }
    catch(err){
        console.error();
        res.status(500).json({
            message: "Error in fetching tasks"
        })
    }
}

async function  completionTask(req,res){
    try{
        const todo = await todomodel.findById(req.params.id);

        if(!todo){
            return res.status(404).json({
               message: "Task not found"
            })
        }

        todo.completed =!(todo.completed);

        const updatedTodo = await todo.save();

        return res.status(200).json({
            message: "Task toggled Successfully",
            updatedTodo
        })

    }
    catch(error){
        console.error();

        res.status(500).json({
            message: "Error in updating task"
        });
    }
}

async function editTask(req,res){
    try{
            const updatedTodo = await todomodel.findByIdAndUpdate(
                req.params.id,
                { title: req.body.title },
                { new: true }
            );
            res.status(200).json({
                message: "Task edited Successfully",
                updatedTodo
            });
        }
        catch(error){
            console.error();
            res.status(500).json({
                message: "Error in editing task"
        })
    }
}

async function deleteTask(req,res){
    try{
        const deleteTodo = await todomodel.findByIdAndDelete(
            req.params.id
        );
        res.status(200).json({
            message: "Task deleted Successfully"
        });
    }
    catch(error){
        console.error();
        res.status(500).json({
            message:"Error in deleting task"
        })
    }
}

module.exports = { createTask, getTask, completionTask, editTask, deleteTask }