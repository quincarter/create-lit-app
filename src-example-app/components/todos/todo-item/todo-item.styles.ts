import { css } from "lit";

export const TodoItemStyles = css`
	:host {
		display: block;
		padding: 0.5rem;
		border-bottom: 1px solid #eee;
	}

	.todo-item {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.todo-item.checked .title {
		text-decoration: line-through;
		color: #888;
	}

	.content {
		flex: 1;
		display: flex;
		flex-direction: column;
	}

	.title {
		font-weight: bold;
	}

	.description {
		font-size: 0.85rem;
		color: #666;
	}

	button {
		background-color: #ff4d4d;
		color: white;
		border: none;
		padding: 0.25rem 0.5rem;
		border-radius: 4px;
		cursor: pointer;
	}

	button:hover {
		background-color: #cc0000;
	}
`;
