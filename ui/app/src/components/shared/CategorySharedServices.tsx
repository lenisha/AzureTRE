import React, { useContext, useEffect, useState } from 'react';
import { Resource } from '../../models/resource';
import { ResourceCardList } from './ResourceCardList';
import { PrimaryButton, Stack } from '@fluentui/react';
import { ResourceType } from '../../models/resourceType';
import { SharedService } from '../../models/sharedService';
import { HttpMethod, useAuthApiCall } from '../../hooks/useAuthApiCall';
import { ApiEndpoint } from '../../models/apiEndpoints';
import { CreateUpdateResourceContext } from '../../contexts/CreateUpdateResourceContext';
import { RoleName, WorkspaceRoleName } from '../../models/roleNames';
import { SecuredByRole } from './SecuredByRole';

interface CategorySharedServiceProps{
  service_category?: string
}

export const CategorySharedServices: React.FunctionComponent<CategorySharedServiceProps> = (props: CategorySharedServiceProps) => {
  const [sharedServices, setSharedServices] = useState([] as Array<SharedService>);
  const apiCall = useAuthApiCall();

  useEffect(() => {
    const getSharedServices = async () => {
      const ss = (await apiCall(`${ApiEndpoint.SharedServicesCategory}/${props.service_category}`, HttpMethod.Get)).sharedServices;
      setSharedServices(ss);
    }
    getSharedServices();
  }, [apiCall,props.service_category]);

  const updateSharedService = (ss: SharedService) => {
    let ssList = [...sharedServices];
    let i = ssList.findIndex((f: SharedService) => f.id === ss.id);
    ssList.splice(i, 1, ss);
    setSharedServices(ssList);
  };

  const removeSharedService = (ss: SharedService) => {
    let ssList = [...sharedServices];
    let i = ssList.findIndex((f: SharedService) => f.id === ss.id);
    ssList.splice(i, 1);
    setSharedServices(ssList);
  };

  const addSharedService = (ss: SharedService) => {
    let ssList = [...sharedServices];
    ssList.push(ss);
    setSharedServices(ssList);
  }

  return (
    <>
      <Stack className="tre-panel">
        <Stack.Item>
          <Stack horizontal horizontalAlign="space-between">
            <h1>{props.service_category} Shared Services</h1>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <ResourceCardList
            resources={sharedServices}
            updateResource={(r: Resource) => updateSharedService(r as SharedService)}
            removeResource={(r: Resource) => removeSharedService(r as SharedService)}
            emptyText="This TRE has no shared services."
            readonly={true} />
        </Stack.Item>
      </Stack>
    </>
  );
};
