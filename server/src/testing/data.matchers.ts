export const userMatcher = {
  id: expect.any(Number),
  firstName: expect.any(String),
  lastName: expect.any(String),
  isActive: expect.any(Boolean),
};

export const choreMatcher = {
  id: expect.any(Number),
  title: expect.any(String),
  description: expect.any(String),
  deadline: expect.any(Date),
};
