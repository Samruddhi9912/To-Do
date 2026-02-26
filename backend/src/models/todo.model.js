const mongoose = require('mongoose')

const todoSchema = new mongoose.Schema({
    title:{
        type: String,
        required: true
    },
    completed:{
        type: Boolean,
        default: false
    },
    targetDate:{
        type: Date,
        required: true
    }
});

const todoModel = mongoose.model("todo",todoSchema)

module.exports = todoModel