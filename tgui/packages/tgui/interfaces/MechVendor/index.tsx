import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  Modal,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  MECHA_ASSEMBLY,
  MECHA_WEAPONS,
  MechVendData,
  MechWeapon,
  tabs,
} from './data';
import { MechAssembly } from './MechAssembly';
import { MechWeapons } from './MechWeapons';

export const MechVendor = (props) => {
  const [showDesc, setShowDesc] = useState<MechWeapon | null>(null);
  const [selectedTab, setSelectedTab] = useState(tabs[0]);
  const { act, data } = useBackend<MechVendData>();
  return (
    <Window title={'Mecha Assembler'} width={1460} height={620}>
      {showDesc ? (
        <Modal width="500px">
          <Section
            title={showDesc.name}
            buttons={
              <Button content="Dismiss" onClick={() => setShowDesc(null)} />
            }
          >
            <Stack>
              <Stack.Item>
                <Box
                  className={classes([
                    'mech_builder64x32',
                    showDesc.icon_state,
                  ])}
                  ml={5}
                  mr={20}
                  mt={3}
                  mb={9}
                  style={{
                    transform: 'scale(3) translate(20%, 20%)',
                  }}
                />
                <LabeledList>
                  <LabeledList.Item label={'Max Integrity'}>
                    {showDesc.health}
                  </LabeledList.Item>
                  <LabeledList.Item label={'Fire rate'}>
                    {showDesc.firerate * 10} per second
                  </LabeledList.Item>
                  {showDesc.burst_count ? (
                    <LabeledList.Item label={'Burst amount'}>
                      {showDesc.burst_count}
                    </LabeledList.Item>
                  ) : null}
                  {showDesc.damage ? (
                    <LabeledList.Item label={'Damage'}>
                      {showDesc.damage}
                    </LabeledList.Item>
                  ) : null}
                  {showDesc.armor_pierce ? (
                    <LabeledList.Item label={'Piercing'}>
                      {showDesc.armor_pierce}
                    </LabeledList.Item>
                  ) : null}
                  {showDesc.projectiles ? (
                    <LabeledList.Item label={'Magazine size'}>
                      {showDesc.projectiles}
                    </LabeledList.Item>
                  ) : null}
                  {showDesc.cache_max ? (
                    <LabeledList.Item label={'Ammo storage size'}>
                      {showDesc.cache_max}
                    </LabeledList.Item>
                  ) : null}
                  {showDesc.scatter ? (
                    <LabeledList.Item label={'Scatter'}>
                      {showDesc.scatter}°
                    </LabeledList.Item>
                  ) : null}
                  {showDesc.burst_amount ? (
                    <LabeledList.Item label={'Burst count'}>
                      {showDesc.burst_amount}
                    </LabeledList.Item>
                  ) : null}
                  <LabeledList.Item label={'Slowdown'}>
                    {showDesc.slowdown}
                  </LabeledList.Item>
                </LabeledList>
              </Stack.Item>
              <Stack.Item>
                <Box ml={-38}>
                  {showDesc.desc +
                    (showDesc.ammo_type
                      ? ' Loaded with: ' + showDesc.ammo_type + '.'
                      : '')}
                </Box>
              </Stack.Item>
            </Stack>
          </Section>
        </Modal>
      ) : null}
      <Window.Content>
        <Tabs fluid>
          {tabs.map((tabname) => {
            return (
              <Tabs.Tab
                key={tabname}
                selected={tabname === selectedTab}
                fontSize="130%"
                textAlign="center"
                onClick={() => setSelectedTab(tabname)}
              >
                {tabname}
              </Tabs.Tab>
            );
          })}
        </Tabs>
        <Stack>
          <Stack.Item>
            <ProgressBar
              style={{
                transform: 'rotate(270deg) translateX(-48%)',
                width: 535,
                marginLeft: -255,
                marginRight: -255,
              }}
              ranges={{
                good: [0.5, Infinity],
                average: [0, 0.5],
                bad: [-Infinity, 0],
              }}
              maxValue={data.max_weight}
              value={data.weight}
            >
              Weight
              {
                // todo have an icon here instead of text so it looks nicer
              }
            </ProgressBar>
          </Stack.Item>
          <Stack.Item>
            {selectedTab === MECHA_ASSEMBLY && <MechAssembly />}
            {selectedTab === MECHA_WEAPONS && (
              <MechWeapons setShowDesc={setShowDesc} />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
