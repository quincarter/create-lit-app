import { css } from "lit";

export const ThemeSwitcherStyles = css`
  :host {
    height: fit-content;
    justify-content: right;
    display: flex;
  }

  .switch {
    position: relative;
    display: inline-block;
    width: 3rem;
    height: 1.5rem;
    -webkit-tap-highlight-color: transparent;
  }

  .switch input {
    opacity: 0;
    width: 0;
    height: 0;
  }

  .slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #27173a;
    -webkit-transition: 0.4s;
    transition: 0.4s;
  }

  .slider:before {
    position: absolute;
    content: '';
    height: 1rem;
    width: 1rem;
    left: 5px;
    bottom: 4px;
    background-color: #ffc207;
    -webkit-transition: 0.4s;
    transition: 0.4s;
  }

  input:checked + .slider {
    background-color: #27173a;
  }

  input:focus + .slider {
    box-shadow: 0 0 2px #27173a;
  }

  input:checked + .slider:before {
    -webkit-transform: translateX(1.5rem);
    -ms-transform: translateX(1.5rem);
    transform: translateX(1.5rem);
    box-shadow: inset -3px 0 0 2px #ffc207;
    background-color: #27173a;
  }

  .slider.round {
    border-radius: 5rem;
  }

  .slider.round:before {
    border-radius: 50%;
  }
`;
