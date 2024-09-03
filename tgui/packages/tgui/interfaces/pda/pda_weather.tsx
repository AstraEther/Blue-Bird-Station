import { decodeHtmlEntities, toTitleCase } from 'common/string';

import { useBackend } from '../../backend';
import { Box, LabeledList, Section } from '../../components';

type Data = {
  weather: Weather[];
};

type Weather = {
  Planet: string;
  Time: string;
  Weather: string;
  Temperature;
  High;
  Low;
  WindDir;
  WindSpeed;
  Forecast: string;
};

// Stolen wholesale from communicators.
export const pda_weather = (props) => {
  const { act, data } = useBackend<Data>();

  const { weather } = data;

  return (
    <Box>
      <Section title="Weather">
        {(!!weather.length && (
          <LabeledList>
            {weather.map((wr) => (
              <LabeledList.Item label={wr.Planet} key={wr.Planet}>
                <LabeledList>
                  <LabeledList.Item label="Time">{wr.Time}</LabeledList.Item>
                  <LabeledList.Item label="Weather">{toTitleCase(wr.Weather)}</LabeledList.Item>
                  <LabeledList.Item label="Temperature">
                    Current: {wr.Temperature.toFixed()}&deg;C | High: {wr.High.toFixed()}&deg;C | Low:{' '}
                    {wr.Low.toFixed()}&deg;C
                  </LabeledList.Item>
                  <LabeledList.Item label="Wind Direction">{wr.WindDir}</LabeledList.Item>
                  <LabeledList.Item label="Wind Speed">{wr.WindSpeed}</LabeledList.Item>
                  <LabeledList.Item label="Forecast">{decodeHtmlEntities(wr.Forecast)}</LabeledList.Item>
                </LabeledList>
              </LabeledList.Item>
            ))}
          </LabeledList>
        )) || <Box color="bad">No weather reports available. Please check back later.</Box>}
      </Section>
    </Box>
  );
};
