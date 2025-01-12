from endia import Array
from endia.utils.aliases import dtype, nelts, NA
import math
from endia.functional._utils import (
    setup_shape_and_data,
)
from ._utils import DifferentiableUnaryOp, unary_op_array, execute_unary_op


####-----------------------------------------------------------------------------------------------------------------####
#### Reciprocal
####-----------------------------------------------------------------------------------------------------------------#####
struct Reciprocal(DifferentiableUnaryOp):
    @staticmethod
    fn fwd(arg0: Array) raises -> Array:
        """Computes the reciprocal of the input array element-wise.

        Args:
            arg0: The input array.

        Returns:
            An array containing the reciprocal of each element in the input array.

        #### Examples:
        ```python
        a = Array([[1, 2], [3, 4]])
        result = reciprocal(a)
        print(result)
        ```

        #### Note:
        This function supports:
        - Automatic differentiation (forward and reverse modes).
        - Complex valued arguments.
        """
        return unary_op_array(
            arg0,
            "reciprocal",
            Reciprocal.__call__,
            Reciprocal.jvp,
            Reciprocal.vjp,
            Reciprocal.unary_simd_op,
        )

    @staticmethod
    fn jvp(primals: List[Array], tangents: List[Array]) raises -> Array:
        """Computes the Jacobian-vector product for the reciprocal function.

        Implements forward-mode automatic differentiation for the reciprocal function.

        Args:
            primals: A list containing the primal input array.
            tangents: A list containing the tangent vector.

        Returns:
            The Jacobian-vector product for the reciprocal function.

        #### Note:
        The Jacobian-vector product for the reciprocal is computed as -x^2 * dx / x^2,
        where x is the primal input and dx is the tangent vector.
        """
        return -primals[0] ** -2

    @staticmethod
    fn vjp(primals: List[Array], grad: Array, out: Array) raises -> List[Array]:
        """Computes the vector-Jacobian product for the reciprocal function.

        Implements reverse-mode automatic differentiation for the reciprocal function.

        Args:
            primals: A list containing the primal input array.
            grad: The gradient of the output with respect to some scalar function.
            out: The output of the forward pass (unused in this function).

        Returns:
            A list containing the gradient with respect to the input.

        #### Note:
        The vector-Jacobian product for the reciprocal is computed as -grad / x^2,
        where x is the primal input and grad is the incoming gradient.
        """
        return -grad / square(primals[0])

    @staticmethod
    fn unary_simd_op(
        arg0_real: SIMD[dtype, nelts[dtype]() * 2 // 2],
        arg0_imag: SIMD[dtype, nelts[dtype]() * 2 // 2],
    ) -> Tuple[
        SIMD[dtype, nelts[dtype]() * 2 // 2],
        SIMD[dtype, nelts[dtype]() * 2 // 2],
    ]:
        """
        Low-level function to compute the reciprocal of a complex number represented as SIMD vectors.

        Args:
            arg0_real: The real part of the complex number.
            arg0_imag: The imaginary part of the complex number.

        Returns:
            The real and imaginary parts of the reciprocal of the complex number as a tuple.
        """
        var denom = arg0_real * arg0_real + arg0_imag * arg0_imag
        var real = arg0_real / denom
        var imag = -arg0_imag / denom
        return real, imag

    @staticmethod
    fn __call__(inout curr: Array, args: List[Array]) raises:
        """Performs the forward pass for element-wise reciprocal computation of an array.

        Computes the reciprocal of each element in the input array and stores the result in the current array.
        Initializes the current array if not already set up.

        Args:
            curr: The current array to store the result (modified in-place).
            args: A list containing the input array.

        #### Note:
        This function assumes that the shape and data of the args are already set up.
        If the current array (curr) is not initialized, it computes the shape based on the input array and sets up the data accordingly.
        """
        setup_shape_and_data(curr)
        execute_unary_op(curr, args)


fn reciprocal(arg0: Array) raises -> Array:
    """Computes the reciprocal of the input array element-wise.

    Args:
        arg0: The input array.

    Returns:
        An array containing the reciprocal of each element in the input array.

    #### Examples:
    ```python
    a = Array([[1, 2], [3, 4]])
    result = reciprocal(a)
    print(result)
    ```

    #### Note:
    This function supports:
    - Automatic differentiation (forward and reverse modes).
    - Complex valued arguments.
    """
    return Reciprocal.fwd(arg0)
