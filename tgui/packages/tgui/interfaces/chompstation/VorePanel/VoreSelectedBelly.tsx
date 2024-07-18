import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { Tabs } from '../../../components';
import { selectedData } from './types';
import { VoreContentsPanel } from './VoreContentsPanel';
import { VoreSelectedBellyControls } from './VoreSelectedBellyControls';
import { VoreSelectedBellyDescriptions } from './VoreSelectedBellyDescriptions';
import { VoreSelectedBellyInteractions } from './VoreSelectedBellyInteractions';
import { VoreSelectedBellyLiquidMessages } from './VoreSelectedBellyLiquidMessages';
import { VoreSelectedBellyLiquidOptions } from './VoreSelectedBellyLiquidOptions';
import { VoreSelectedBellyOptions } from './VoreSelectedBellyOptions';
import { VoreSelectedBellySounds } from './VoreSelectedBellySounds';
import { VoreSelectedBellyVisuals } from './VoreSelectedBellyVisuals';
/**
 * Subtemplate of VoreBellySelectionAndCustomization
 */
export const VoreSelectedBelly = (props: {
  belly: selectedData;
  show_pictures: BooleanLike;
  icon_overflow: BooleanLike;
}) => {
  const { belly, show_pictures, icon_overflow } = props;
  const { contents } = belly;

  const [tabIndex, setTabIndex] = useState(0);

  const tabs: React.JSX.Element[] = [];

  tabs[0] = <VoreSelectedBellyControls belly={belly} />;
  tabs[1] = <VoreSelectedBellyDescriptions belly={belly} />;
  tabs[2] = <VoreSelectedBellyOptions belly={belly} />;
  tabs[3] = <VoreSelectedBellySounds belly={belly} />;
  tabs[4] = <VoreSelectedBellyVisuals belly={belly} />;
  tabs[5] = <VoreSelectedBellyInteractions belly={belly} />;
  tabs[6] = (
    <VoreContentsPanel
      outside
      contents={contents}
      show_pictures={show_pictures}
      icon_overflow={icon_overflow}
    />
  );
  tabs[7] = <VoreSelectedBellyLiquidOptions belly={belly} />;
  tabs[8] = <VoreSelectedBellyLiquidMessages belly={belly} />;

  return (
    <>
      <Tabs>
        <Tabs.Tab selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
          Controls
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
          Descriptions
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 2} onClick={() => setTabIndex(2)}>
          Options
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 3} onClick={() => setTabIndex(3)}>
          Sounds
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 4} onClick={() => setTabIndex(4)}>
          Visuals
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 5} onClick={() => setTabIndex(5)}>
          Interactions
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 6} onClick={() => setTabIndex(6)}>
          Contents ({contents.length})
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 7} onClick={() => setTabIndex(7)}>
          Liquid Options
        </Tabs.Tab>
        <Tabs.Tab selected={tabIndex === 8} onClick={() => setTabIndex(8)}>
          Liquid Messages
        </Tabs.Tab>
      </Tabs>
      {tabs[tabIndex] || 'Error'}
    </>
  );
};
