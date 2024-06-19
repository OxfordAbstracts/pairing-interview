import { expect, test } from 'vitest';
import { main } from "../../output/Web.Main/index.js";
import { screen } from '@testing-library/dom';

test('it renders', async () => {
  main();
  await screen.findByRole('table');
  expect(screen.queryByText('Loading')).not.toBeInTheDocument();

  // TODO: test data is rendered in the table after fetch
})
