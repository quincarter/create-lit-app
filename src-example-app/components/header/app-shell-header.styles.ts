import { css } from "lit";

export const AppShellHeaderStyles = css`
  .logo {
    height: 2rem;
  }

  nav {
    align-items: center;
    background-color: var(--nav-background-color);
    box-shadow: var(--primary-box-shadow);
    display: grid;
    grid-template-columns: 1fr 6fr 2fr;
    gap: 1rem;
    padding-inline: 1rem;
  }

  ul {
    display: flex;
    flex-direction: row;
    gap: 2rem;
    list-style: none;
  }

  a {
    font-weight: 500;
    color: var(--primary-text-color);
    text-decoration: none;
  }

  a:hover {
    text-decoration: underline;
  }
`;
