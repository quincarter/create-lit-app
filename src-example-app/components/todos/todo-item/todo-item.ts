import { TodoItem } from "./TodoItem";

customElements.get("todo-item") || customElements.define("todo-item", TodoItem);
