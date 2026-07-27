import { TodoList } from "./TodoList";

customElements.get("todo-list") || customElements.define("todo-list", TodoList);
