import React, { useState } from 'react';
import {
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Avatar,
  Chip,
  Tooltip,
  TablePagination,
  Box,
  Typography
} from '@mui/material';
import {
  Visibility as VisibilityIcon,
  Edit as EditIcon,
  Delete as DeleteIcon
} from '@mui/icons-material';

const UserTable = ({ users, userType, onView, onEdit, onDelete }) => {
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  const handleChangePage = (event, newPage) => {
    setPage(newPage);
  };

  const handleChangeRowsPerPage = (event) => {
    setRowsPerPage(parseInt(event.target.value, 10));
    setPage(0);
  };

  const getStatusColor = (status) => {
    switch (status.toLowerCase()) {
      case 'active':
        return 'success';
      case 'inactive':
        return 'error';
      case 'pending':
        return 'warning';
      default:
        return 'default';
    }
  };

  // Empty state when no users
  if (!users || users.length === 0) {
    return (
      <Paper
        sx={{
          p: 5,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center'
        }}
      >
        <Box sx={{ mb: 2, color: 'text.secondary' }}>
          <Typography variant="h6">No {userType} found</Typography>
          <Typography variant="body2" align="center">
            There are no {userType.toLowerCase()} registered in the system.
          </Typography>
        </Box>
      </Paper>
    );
  }

  return (
    <Paper sx={{ width: '100%', overflow: 'hidden' }}>
      <TableContainer sx={{ maxHeight: 600 }}>
        <Table stickyHeader aria-label={`${userType} table`}>
          <TableHead>
            <TableRow>
              <TableCell>Name/Organization</TableCell>
              <TableCell>Contact</TableCell>
              <TableCell>Email</TableCell>
              <TableCell>Type</TableCell>
              <TableCell>Joined</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {users
              .slice(page * rowsPerPage, page * rowsPerPage + rowsPerPage)
              .map((user) => (
                <TableRow hover key={user.id}>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center' }}>
                      <Avatar
                        alt={user.name}
                        src={user.profileImage}
                        sx={{ width: 40, height: 40, mr: 2 }}
                      />
                      <Box>
                        <Typography variant="body1" fontWeight="medium">
                          {user.organization || user.name}
                        </Typography>
                        {user.organization && (
                          <Typography variant="caption" color="text.secondary">
                            {user.name}
                          </Typography>
                        )}
                      </Box>
                    </Box>
                  </TableCell>
                  <TableCell>{user.phone}</TableCell>
                  <TableCell>{user.email}</TableCell>
                  <TableCell>
                    <Chip 
                      label={user.type} 
                      size="small" 
                      color="primary" 
                      variant="outlined"
                    />
                  </TableCell>
                  <TableCell>{new Date(user.joinDate).toLocaleDateString()}</TableCell>
                  <TableCell>
                    <Chip 
                      label={user.status} 
                      size="small" 
                      color={getStatusColor(user.status)} 
                    />
                  </TableCell>
                  <TableCell align="right">
                    <Tooltip title="View details">
                      <IconButton size="small" onClick={() => onView(user)}>
                        <VisibilityIcon fontSize="small" />
                      </IconButton>
                    </Tooltip>
                    <Tooltip title="Edit">
                      <IconButton size="small" onClick={() => onEdit(user)}>
                        <EditIcon fontSize="small" />
                      </IconButton>
                    </Tooltip>
                    <Tooltip title="Delete">
                      <IconButton size="small" color="error" onClick={() => onDelete(user)}>
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </Tooltip>
                  </TableCell>
                </TableRow>
              ))}
          </TableBody>
        </Table>
      </TableContainer>
      <TablePagination
        rowsPerPageOptions={[5, 10, 25]}
        component="div"
        count={users.length}
        rowsPerPage={rowsPerPage}
        page={page}
        onPageChange={handleChangePage}
        onRowsPerPageChange={handleChangeRowsPerPage}
      />
    </Paper>
  );
};

export default UserTable; 