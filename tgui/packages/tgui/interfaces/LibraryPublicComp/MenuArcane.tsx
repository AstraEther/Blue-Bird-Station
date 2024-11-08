import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
import { Data } from './types';

export const MenuArcane = (props) => {
  const { act, data } = useBackend<Data>();

  return (
    <Section title="Forbidden Lore Vault v1.4">
      <center>
        Are you absolutely sure you want to proceed? EldritchTomes Inc. takes no
        responsibilities for loss of sanity resulting from this action.
        <br />
        <Button.Confirm
          icon="eye"
          onClick={() =>
            act('switchscreen', { arcane_checkout: 'arcane_checkout' })
          }
        >
          Accept Responsibility
        </Button.Confirm>
      </center>
    </Section>
  );
};
