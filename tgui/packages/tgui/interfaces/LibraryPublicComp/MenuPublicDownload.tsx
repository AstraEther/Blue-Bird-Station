import { useBackend } from '../../backend';
import { Box, Divider, Section } from '../../components';
import { MenuPageChanger } from './MenuParts';
import { Data } from './types';

export const MenuPublicDownload = (props) => {
  const { act, data } = useBackend<Data>();

  const { inventory } = data;

  return (
    <Section title="Exonet Catalog">
      {inventory.length > 0 ? (
        inventory.map((book) => (
          <Section title={book.title} key={book.id}>
            {book.author} - {book.category}
            <Divider />
          </Section>
        ))
      ) : (
        <Box>
          <br />
          <center>
            <h2>CANNOT CONNECT</h2>
          </center>
          <br />
          <center>Contact a librarian for support.</center>
        </Box>
      )}
      <Divider />
      <MenuPageChanger />
    </Section>
  );
};
