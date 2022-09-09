import React, { useContext } from 'react';
import { Nav, INavLinkGroup } from '@fluentui/react/lib/Nav';
import { useNavigate } from 'react-router-dom';
import { AppRolesContext } from '../../contexts/AppRolesContext';
import { RoleName } from '../../models/roleNames';

export const LeftNav: React.FunctionComponent = () => {
  const navigate = useNavigate();
  const appRolesCtx = useContext(AppRolesContext);

  const navLinkGroups: INavLinkGroup[] = [
    {
      links: [
        {
          name: 'Workspaces',
          url: '/',
          key: '/',
          icon: 'WebAppBuilderFragment'
        },
        {
          name: 'Data',
          url: '/shared-services/category/data',
          key: 'shared-services-category',
          icon: 'Database'
        },
        {
          name: 'Compute',
          url: '/shared-services/category/compute',
          key: 'shared-services-category',
          icon: 'CloudAdd'
        },
        {
          name: 'Training & Support',
          url: '/shared-services/category/training',
          key: 'shared-services-category',
          icon: 'Info'
        },
        {
          name: 'Infrastructure',
          url: '/shared-services/category/infrastructure',
          key: 'shared-services-category',
          icon: 'Toolbox'
        }
      ],
    },
  ];

  // show shared-services link if TRE Admin
  if (appRolesCtx.roles.includes(RoleName.TREAdmin)) {
    navLinkGroups[0].links.push(
      {
        name: 'Shared Services',
        url: '/shared-services',
        key: 'shared-services',
        icon: 'Puzzle'
      });
  }

  return (
    <Nav
      onLinkClick={(e, item) => { e?.preventDefault(); item?.url && navigate(item.url) }}
      ariaLabel="TRE Left Navigation"
      groups={navLinkGroups}
    />
  );
};

