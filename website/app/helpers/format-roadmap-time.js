import { helper } from '@ember/component/helper';
import moment from 'moment';

export function formatRoadmapTime([epochTime, strategy]) {
  if (strategy === 'relative') {
    return moment.unix(epochTime).utc().fromNow();
  } else if (strategy === 'friendly') {
    return moment.unix(epochTime).format("MMMM Do YYYY, h:mm A");
  }
}

export default helper(formatRoadmapTime);
