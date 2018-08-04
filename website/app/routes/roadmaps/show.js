import Route from '@ember/routing/route';
import RouteQueryManager from "ember-apollo-client/mixins/route-query-manager";
import query from "website/gql/queries/roadmap";

export default Route.extend(RouteQueryManager, {
  model(params) {
    let variables = { id: parseInt(params.roadmap_id, 10) };
    return this.get('apollo').watchQuery({ query, variables }, "roadmap");
  }
});
